@echo off
REM dougvikt - 2025
mode 65,30
setlocal EnableDelayedExpansion
title TI SUBREMO - Ferramenta do TI
color 0A

:: Verifica se o script está sendo executado como administrador
net session >nul 2>&1
if %errorlevel% equ 0 (
    call :main_menu
    exit
) else (
    echo Este script deve ser executado como Administrador!
    echo Tentando reiniciar como administrador...
    :: Reinicia o próprio script como administrador
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b 1
    
)


:: Menu principal 
:main_menu
cls
echo ================================================================
echo   	              FERRAMENTA SUPREMA DO TI
echo ================================================================
echo.
echo               [ 1 ] ==== APLICATIVOS 
echo               [ 2 ] ==== SISTEMA 
echo               [ 3 ] ==== REDE 
echo               [ 4 ] ==== UTILIARIOS 
echo               [ 5 ] ==== SAIR 

set /p choice0="  Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice0!"=="1" call :aplications & goto :main_menu
if "!choice0!"=="2" call :system & goto :main_menu
if "!choice0!"=="3" call :network & goto :main_menu
if "!choice0!"=="4" call :utilities & goto :main_menu
if "!choice0!"=="5" exit 


:: submenu de aplicativos
:aplications
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE APLICATIVOS
echo ================================================================
echo.
echo           [ 1 ] = INSTALAR PROGRAMAS DO ARQUIVO TXT 
echo           [ 2 ] = VERIFICAR PROGRAMAS INSTALADOS
echo           [ 3 ] = ATUALIZAR PROGRAMAS INSTALADOS
echo           [ 4 ] = VOLTAR AO MENU PRINCIPAL

set /p choice1="Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice1!"=="1" call :install_apps_txt
if "!choice1!"=="2" call :check_installed_apps
if "!choice1!"=="3" call :update_installed_apps
if "!choice1!"=="4" goto :eof
goto :aplications

:: submenu de sistema
:system
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE SISTEMA
echo ================================================================
echo.
echo 1 = VERIFICAR USO DE DISCO
echo 2 = VERIFICAR USO DE MEMÓRIA
echo 3 = VERIFICAR USO DE CPU
echo 4 = LIMPAR ARQUIVOS TEMP
echo 5 = LIMPEZA DE REGISTRO
echo 6 = LIMPEZA DE DISCO 
echo 7 = CORRIGIR PROBLEMAS NO SISTEMA
echo 8 = VERIFICAR INTEGRIDADE DO SISTEMA
echo 9 = RESTAURAR INTEGRIDADE DO SISTEMA
echo 0 = VOLTAR AO MENU PRINCIPAL  

set /p choice2="Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice2!"=="1" call :check_disk_usage
if "!choice2!"=="2" call :check_memory_usage
if "!choice2!"=="3" call :check_cpu_usage
if "!choice2!"=="4" call :clear_temp_files
if "!choice2!"=="5" call :check_system_services
if "!choice2!"=="6" call :disk_cleanup
if "!choice2!"=="7" call :fix_system_issues
if "!choice2!"=="8" goto :eof
goto :system

:: submenu de rede
:network
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE REDE                            
echo ================================================================
echo.
echo 1 = VERIFICAR CONEXÃO COM A INTERNET
echo 2 = VERIFICAR ENDEREÇO IP
echo 3 = VERIFICAR CONFIGURAÇÕES DE REDE
echo 4 = VERIFICAR USO DE LARGURA DE BANDA
echo 5 = VERIFICAR SERVIÇOS DE REDE
echo 6 = DEFINIR DNS PARA GOOGLE
echo 7 = DEFINIR DNS PARA CLOUDFARE
echo 8 = DEFINIR DNS PARA OPENDNS
echo 9 = ADICIONAR DNS PERSONALIZADO
echo 9 = RESTAURAR DNS PARA PADRÃO
echo 10 = REINICIAR ATAPTADORES DE REDE 
echo 6 = VOLTAR AO MENU PRINCIPAL

set /p choice3="Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice3!"=="1" call :check_internet_connection
if "!choice3!"=="2" call :check_ip_address
if "!choice3!"=="3" call :check_network_config
if "!choice3!"=="4" call :check_bandwidth_usage
if "!choice3!"=="5" call :check_network_services
if "!choice3!"=="6" goto :set_google_dns
if "!choice3!"=="7" goto :set_cloudflare_dns
if "!choice3!"=="8" goto :set_opendns
if "!choice3!"=="9" call :add_custom_dns
if "!choice3!"=="10" call :restore_default_dns
if "!choice3!"=="11" call :restart_network_adapters
if "!choice3!"=="12" goto :eof
goto :network

:: submenu de utilitários
:utilities
cls
echo ================================================================
echo   	    MENU FERRAMENTAS DE UTILITARIOS
echo ================================================================
echo.
echo 1 = VERIFICAR USO DE DISCO
echo 2 = VERIFICAR USO DE MEMÓRIA
echo 3 = VERIFICAR USO DE CPU
echo 4 = LIMPAR ARQUIVOS TEMP
echo 5 = VERIFICAR SERVIÇOS DO SISTEMA
echo 6 = LIMPEZA DE REGISTRO
echo 7 = GERAR RELATORIO DO SISTEMA
echo 8 = VOLTAR AO MENU PRINCIPAL

set /p choice4="Escolha uma opcao: "

:: Verifica a opção escolhida
if "!choice4!"=="1" call :check_disk_usage
if "!choice4!"=="2" call :check_memory_usage
if "!choice4!"=="3" call :check_cpu_usage
if "!choice4!"=="4" call :clear_temp_files
if "!choice4!"=="5" call :check_system_services
if "!choice4!"=="6" call :clean_registry
if "!choice4!"=="7" call :disk_cleanup
if "!choice4!"=="8" goto :eof
goto :utilities


::      AREA DAS FUNÇOES 
:: =================================
:: Referente ao submenu de aplicativos
:: =================================

::       Escolha = 1
:: -------------------------
:install_apps_txt
cls 
echo Instalando programas do arquivo TXT...
pause
goto :eof

::      Escolha = 2
:: -------------------------
:update_installed_apps
:: Atualizndo todos os aplicativos instalados via Winget
cls
echo Atualizando TODOS os aplicativos via Winget...
echo.
echo Esta operacao pode demorar varios minutos.
echo.
set /p confirmar="Confirmar atualizacao de TODOS os aplicativos? (S/N): "
if /i "%confirmar%"=="S" (
    :: Verificação do Winget 
    call :check_winget 
    echo Iniciando atualizacao completa...
    winget upgrade --all --accept-package-agreements --accept-source-agreements --silent
    echo.
    echo Atualizacao completa concluida!
) else (
    echo Atualizacao cancelada.
)
pause
goto :eof

:: verificando o Winget 
:check_winget
call :verify_winget
if errorlevel 1 (
    echo Nao foi possivel executar o Winget.
    pause
    exit /b 1
)

:verify_winget
:: Verifica se o Winget está instalado e funcionando
echo Verificando Winget...
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Winget nao encontrado no PATH.
    call :fix_winget_path
    if errorlevel 1 (
        echo Falha ao corrigir Winget.
        exit /b 1
    )
)

:: Testar se winget funciona
winget --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Winget encontrado mas nao funciona.
    call :diagnose_winget
    exit /b 1
)

echo Winget funcionando: OK
exit /b 0

:: Resolvendo problemas do Winget no path
:fix_winget_path
echo Tentando corrigir o PATH do Winget...

for /f "tokens=*" %%i in ('powershell "(Get-AppxPackage Microsoft.DesktopAppInstaller).InstallLocation 2>$null"') do set "wingetPath=%%i"

if "%wingetPath%"=="" (
    echo ERRO: Nao foi possivel encontrar o Winget.
    exit /b 1
)

if not exist "%wingetPath%\winget.exe" (
    echo ERRO: Arquivo winget.exe nao encontrado.
    exit /b 1
)

:: Adicionar ao PATH temporariamente
set "PATH=%wingetPath%;%PATH%"

:: Testar novamente
winget --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Winget ainda nao funciona apos correcao.
    exit /b 1
)

echo Correcao bem-sucedida!
exit /b 0

:diagnose_winget
echo.
echo Executando diagnostico do Winget...
echo.

:: Verificar se App Installer está instalado
powershell -Command "`$package = Get-AppxPackage Microsoft.DesktopAppInstaller; if (-not `$package) { Write-Host 'ERRO: App Installer nao instalado' -ForegroundColor Red; exit 1 } else { Write-Host 'App Installer: ' `$package.Version -ForegroundColor Green }"

:: Verificar permissões
echo Verificando permissoes...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo AVISO: Execute como Administrador para melhor resultado.
)

:: Tentar reinstalação
echo.
set /p reinstall="Deseja tentar reinstalar o Winget? (S/N): "
if /i "%reinstall%"=="S" (
    call :reinstall_winget
    exit /b %errorlevel%
)

exit /b 1

:: Reinstalando o Winget
:reinstall_winget
echo Reinstalando Winget...
echo.

powershell -Command "try { Get-AppxPackage Microsoft.DesktopAppInstaller | Remove-AppxPackage -ErrorAction Stop; Write-Host 'Remocao bem-sucedida' -ForegroundColor Green } catch { Write-Host 'Erro na remocao: ' `$_.Exception.Message -ForegroundColor Red; exit 1 }"

echo Instalando Winget...
powershell -Command "try { Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop; Write-Host 'Instalacao bem-sucedida' -ForegroundColor Green } catch { Write-Host 'Erro na instalacao: ' `$_.Exception.Message -ForegroundColor Red; exit 1 }"

timeout /t 5 /nobreak >nul

:: Verificar se funcionou
winget --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Reinstalacao falhou.
    exit /b 1
)

echo Reinstalacao bem-sucedida!
exit /b 0


:: refente ao submenu de sistema

:: referente ao submenu de rede

:: referente ao submenu de utilitários