@echo off
REM dougvikt - 2025
mode 65,200
setlocal EnableDelayedExpansion
title TI SUPREMO - Ferramenta do TI
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
echo               [ 0 ] ==== SAIR 

set /p choice0="  Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice0!"=="1" call :aplications & goto :main_menu
if "!choice0!"=="2" call :system & goto :main_menu
if "!choice0!"=="3" call :network & goto :main_menu
if "!choice0!"=="4" call :utilities & goto :main_menu
if "!choice0!"=="0" exit 


:: submenu de aplicativos
:aplications
cls
:aplications
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE APLICATIVOS
echo ================================================================
echo.
echo           [ 1 ]  = INSTALAR PROGRAMAS DO ARQUIVO TXT 
echo           [ 2 ]  = VERIFICAR PROGRAMAS INSTALADOS
echo           [ 3 ]  = ATUALIZAR PROGRAMAS INSTALADOS
echo           [ 4 ]  = SALVAR LISTA DOS INSTALADOS EM ARQUIVO
echo           [ 5 ]  = DESINSTALAR PROGRAMAS ESPECÍFICOS
echo           [ 6 ]  = REPARAR PROGRAMAS INSTALADOS  
echo           [ 7 ]  = LIMPAR CACHE DE APLICATIVOS
echo           [ 8 ]  = VERIFICAR PROGRAMAS COM INICIAL AUTOMÁTICA
echo           [ 9 ]  = OTIMIZAR INICIALIZAÇÃO DE PROGRAMAS
echo           [ 10 ] = VERIFICAR APLICATIVOS VULNERÁVEIS
echo           [ 0 ]  = VOLTAR AO MENU PRINCIPAL     

set /p choice1="Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice1!"=="1" call :install_apps_txt
if "!choice1!"=="2" call :check_installed_apps
if "!choice1!"=="3" call :update_installed_apps
if "!choice1!"=="4" call :save_installed_apps_list
if "!choice1!"=="5" call :uninstall_specific_apps
if "!choice1!"=="6" call :repair_installed_apps
if "!choice1!"=="7" call :clear_app_cache
if "!choice1!"=="8" call :check_startup_apps
if "!choice1!"=="9" call :optimize_startup_apps
if "!choice1!"=="10" call :check_vulnerable_apps
if "!choice1!"=="0" goto :eof
goto :aplications

:: submenu de sistema
:system
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE SISTEMA
echo ================================================================
echo.
echo            [ 1 ] = VERIFICAR USO DE DISCO
echo            [ 2 ] = VERIFICAR USO DE MEMORIA
echo            [ 3 ] = VERIFICAR USO DE CPU
echo            [ 4 ] = LIMPAR ARQUIVOS TEMP
echo            [ 5 ] = LIMPEZA DE REGISTRO
echo            [ 6 ] = LIMPEZA DE DISCO 
echo            [ 7 ] = CORRIGIR PROBLEMAS NO SISTEMA
echo            [ 8 ] = VERIFICAR INTEGRIDADE DO SISTEMA
echo            [ 9 ] = RESTAURAR INTEGRIDADE DO SISTEMA
echo            [ 0 ] = VOLTAR AO MENU PRINCIPAL  

set /p choice2="Escolha uma opcao: "
:: Verifica a opção escolhida
if "!choice2!"=="1" call :check_disk_usage
if "!choice2!"=="2" call :check_memory_usage
if "!choice2!"=="3" call :check_cpu_usage
if "!choice2!"=="4" call :clear_temp_files
if "!choice2!"=="5" call :check_system_services
if "!choice2!"=="6" call :disk_cleanup
if "!choice2!"=="7" call :fix_system_issues
if "!choice2!"=="8" call :check_system_integrity
if "!choice2!"=="9" call :restore_system_integrity
if "!choice2!"=="0" goto :eof
goto :system

:: submenu de rede
:network
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE REDE                            
echo ================================================================
echo.
echo            [ 1 ]  = VERIFICAR CONEXÃO COM A INTERNET
echo            [ 2 ]  = VERIFICAR ENDEREÇO IP
echo            [ 3 ]  = VERIFICAR CONFIGURAÇÕES DE REDE
echo            [ 4 ]  = VERIFICAR USO DE LARGURA DE BANDA
echo            [ 5 ]  = VERIFICAR SERVIÇOS DE REDE
echo            [ 6 ]  = DEFINIR DNS PARA GOOGLE
echo            [ 7 ]  = DEFINIR DNS PARA CLOUDFARE
echo            [ 8 ]  = DEFINIR DNS PARA OPENDNS
echo            [ 9 ]  = ADICIONAR DNS PERSONALIZADO
echo            [ 10 ] = RESTAURAR DNS PARA PADRÃO
echo            [ 11 ] = REINICIAR ATAPTADORES DE REDE 
echo            [ 0 ]  = VOLTAR AO MENU PRINCIPAL

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
if "!choice3!"=="0" goto :eof
goto :network

:: submenu de utilitários
:utilities
cls
echo ================================================================
echo   	              MENU FERRAMENTAS DE UTILITARIOS
echo ================================================================
echo.
echo            [ 1 ] = VERIFICAR USO DE DISCO
echo            [ 2 ] = VERIFICAR USO DE MEMÓRIA
echo            [ 3 ] = VERIFICAR USO DE CPU
echo            [ 4 ] = LIMPAR ARQUIVOS TEMP
echo            [ 5 ] = VERIFICAR SERVIÇOS DO SISTEMA
echo            [ 6 ] = LIMPEZA DE REGISTRO
echo            [ 7 ] = GERAR RELATORIO DO SISTEMA
echo            [ 8 ] = CRIAR PONTO DE RESTAURACAO
echo            [ 9 ] = CRIA USUARIO ADMINISTRADOR
echo            [ 10 ] = ATIVAR CONTA DE ADMINISTRADOR INTERNO
echo            [ 11 ] = DESATIVAR CONTA DE ADMINISTRADOR INTERNO
echo            [ 12 ] = ATIVAR MODO DE SEGURANCA
echo            [ 13 ] = ATIVAR HIRBERNAR
echo            [ 14 ] = DESATIVAR HIBERNAR
echo            [ 0 ] = VOLTAR AO MENU PRINCIPAL

set /p choice4="Escolha uma opcao: "

:: Verifica a opção escolhida
if "!choice4!"=="1" call :check_disk_usage
if "!choice4!"=="2" call :check_memory_usage
if "!choice4!"=="3" call :check_cpu_usage
if "!choice4!"=="4" call :clear_temp_files
if "!choice4!"=="5" call :check_system_services
if "!choice4!"=="6" call :clean_registry
if "!choice4!"=="7" call :disk_cleanup
if "!choice4!"=="8" call :generate_system_report
if "!choice4!"=="9" call :create_admin_user
if "!choice4!"=="10" call :enable_builtin_admin
if "!choice4!"=="11" call :disable_builtin_admin
if "!choice4!"=="12" call :enable_safe_mode
if "!choice4!"=="13" call :enable_hibernation
if "!choice4!"=="14" call :disable_hibernation
if "!choice4!"=="0" goto :eof
goto :utilities



::              AREA DAS FUNÇOES 
:: ===================================================

:: Referente ao submenu de aplicativos
:: =================================

::       Escolha = 1
:: -------------------------
:install_apps_txt
cls 
set /p name_file="Digite o nome do arquivo ( não colocar o .txt ) : "
echo O progrma verifica o arquivo %name_file%.txt na pasta do script.
echo Cada linha do arquivo deve conter o ID do pacote conforme o Winget.
echo Linhas vazias ou que comecem com # serao ignoradas.
echo Certifique-se de que o arquivo esta de acordo para ter sucesso .
pause
echo Instalando programas do arquivo TXT...
set "txtfile=%name_file%.txt"
if not exist "%txtfile%" (
    echo  Erro: Arquivo %~dp0%name_file%.txt não encontrado.
    pause
    goto :eof
)
:: Verifica se o winget está instalado
echo Verificando se o winget esta instalado e funcionando 
:: Usa a mesma função da escolha 2 
call :check_winget
:: Lê cada linha do arquivo e instala o pacote
set "successCount=0"
set "failCount=0"
for /f "tokens=*" %%i in (%txtfile%) do (
    set "package=%%i"
    if not "!package!"=="" if not "!package:~0,1!"=="#" (
        echo Instalando !package!...
        winget install --id !package! -e --silent
        if !errorlevel! equ 0 (
            echo !package! instalado com sucesso.
            set /a successCount+=1
        ) else (
            echo Falha ao instalar !package!.
            set /a failCount+=1
        )
    )
)
color 0A
echo.
echo Instalacao terminada:[ %successCount% ] sucesso , [ %failCount% ] falhou.
pause
goto :eof


::      Escolha = 2
:: -------------------------
:check_installed_apps
:: Verifica os aplicativos instalados 
cls
echo Verificando aplicativos instalados ...
echo.
powershell.exe -Command "$apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher | Sort-Object DisplayName; $apps | Format-Table -AutoSize; Write-Host 'Total de aplicativos: ' $apps.Count -ForegroundColor Cyan"
pause
goto :eof


::      Escolha = 3
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
goto :eof


::      Escolha = 4
:: -------------------------
:save_installed_apps_list
:: Salvando a lista de aplicativos instalados em um arquivo TXT
cls
echo A lista sera salva no arquivo instalado_apps.txt
echo Salvando lista de aplicativos...
winget list > "%~dp0installed_apps.txt" 
if %errorlevel% equ 0 (
    echo Lista de programas instalados salva em installed_apps.txt.
) else (
    echo Algo deu errado ao processar a lista de programas.
)
pause
goto :eof

::      Escolha = 5
:: -------------------------
:uninstall_specific_apps
cls
echo Desinstalar programas especificos via Winget.
echo.
set /p app_name="Digite o nome ou parte do nome do aplicativo a desinstalar: "
if "%app_name%"=="" (
    echo Nenhum nome fornecido. Operacao cancelada.
    pause
    goto :eof
)   



:: Refente ao submenu de sistema
:: =================================

::     Escolha = 1
:: -------------------------
:check_disk_usage
cls
echo Verificando uso dos discos...
:: Verifica o uso do disco
powershell -command ("Get-WmiObject Win32_LogicalDisk | ForEach-Object 
{ $totalMB = [math]::Round($_.Size / 1MB); $freeMB = [math]::Round($_.FreeSpace / 1MB); Write-Output ('Unidade {0}: Total: {1} MB - Livre: {2} MB' -f $_.DeviceID, $totalMB, $freeMB) }"
)
pause
goto :eof

:: referente ao submenu de rede

:: referente ao submenu de utilitários