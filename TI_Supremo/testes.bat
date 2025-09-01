@echo off
setlocal enabledelayedexpansion
cls
echo ================================================================
echo                 DESINSTALAR PROGRAMAS
echo ================================================================
echo.
echo Listando programas instalados...
echo.

:: Gerar lista temporária de programas
wmic product get name | findstr /v /i "Name Update" | sort > %temp%\app_list.txt

:: Mostrar programas paginados
setlocal enabledelayedexpansion
set /a count=0
echo --------------------------
for /f "tokens=*" %%i in (%temp%\app_list.txt) do (
    set /a count+=1
    echo [!count!] %%i
)
echo.

:ask_choice
set /p "choice=Digite o NUMERO do programa para desinstalar ou 'V' para voltar: "
if /i "!choice!"=="V" goto :aplications

:: Validar escolha
set /a valid_choice=0
for /f "tokens=*" %%i in (%temp%\app_list.txt) do (
    set /a line_num+=1
    if !line_num! equ !choice! (
        set "selected_app=%%i"
        set /a valid_choice=1
    )
)

if !valid_choice! equ 0 (
    echo.
    echo ERRO: Numero invalido! Digite um numero entre 1 e !line_num!
    echo.
    set line_num=0
    goto ask_choice
)

:: Confirmar desinstalação
echo.
echo PROGRAMA SELECIONADO: !selected_app!
echo.
set /p "confirm=Deseja realmente desinstalar este programa? (S/N): "
if /i not "!confirm!"=="S" (
    echo Desinstalacao cancelada.
    timeout /t 2 /nobreak >nul
    goto uninstall_specific_apps
)

:: Tentar desinstalar
echo.
echo Desinstalando !selected_app!...
echo.

:: Método 1: WMIC
wmic product where name="!selected_app!" call uninstall 2>&1 | find "ReturnValue" >nul
if !errorlevel! equ 0 (
    echo ✓ Programa desinstalado com sucesso via WMIC!
) else (
    echo ✗ Falha na desinstalacao via WMIC. Tentando metodo alternativo...
    
    :: Método 2: MSIEXEC (se for aplicativo MSI)
    for /f "tokens=2 delims={}" %%a in ('wmic product where "name='!selected_app!'" get IdentifyingNumber /value') do (
        set "product_id=%%a"
    )
    
    if defined product_id (
        echo Tentando desinstalar via MSIEXEC...
        msiexec /x !product_id! /qn /norestart
        if !errorlevel! equ 0 (
            echo ✓ Programa desinstalado com sucesso via MSIEXEC!
        ) else (
            echo ✗ Falha na desinstalacao via MSIEXEC.
        )
    ) else (
        :: Método 3: Procurar no Uninstall registry
        echo Procurando metodo alternativo de desinstalacao...
        set found=0
        for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "!selected_app!" 2^>nul') do (
            if "%%a"=="DisplayName" (
                set "uninstall_key=%%b"
                set found=1
            )
        )
        
        if !found! equ 1 (
            for /f "tokens=2*" %%a in ('reg query "!uninstall_key!" /v UninstallString 2^>nul') do (
                set "uninstall_cmd=%%b"
            )
            if defined uninstall_cmd (
                echo Executando: !uninstall_cmd!
                !uninstall_cmd! /SILENT /VERYSILENT /S
                echo ✓ Comando de desinstalacao executado!
            )
        ) else (
            echo ✗ Nao foi possivel encontrar metodo de desinstalacao.
            echo.
            echo RECOMENDACOES:
            echo 1. Tente desinstalar manualmente pelo Painel de Controle
            echo 2. Use a ferramenta oficial de desinstalacao do fabricante
            echo 3. Verifique se o programa ainda esta instalado
        )
    )
)

:: Limpar arquivo temporário
del %temp%\app_list.txt 2>nul

echo.
echo Pressione qualquer tecla para voltar ao menu...
pause
goto :eof
