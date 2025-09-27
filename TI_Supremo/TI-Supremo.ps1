# Define o título da janela do PowerShell
$Host.UI.RawUI.WindowTitle = "TI Supremo - Ferramenta do TI"
# Configurar cores do console
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

# Verifica se a sessão é Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    # Se não for admin, relança o script com privilégios elevados
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process powershell -Verb RunAs -ArgumentList $argList
    exit
}

# Configuração inteligente do buffer
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(65, 500)
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(65, 40)

# Função para ajustar buffer automaticamente
function Optimize-DisplayForContent {
    param([int]$expectedLines = 500)
    $currentBuffer = $host.UI.RawUI.BufferSize.Height
    $neededBuffer = [Math]::Max($expectedLines * 2, 300)
    
    if ($currentBuffer -lt $neededBuffer) {
        $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(50, $neededBuffer)
    }
}

# Função para exibir o menu principal
function MainMenu {
    $running = $true
    do {
        Clear-Host
        Write-Output "================================================================"
        Write-Output "                  FERRAMENTA SUPREMA DO TI"
        Write-Output "================================================================"
        Write-Output ""
        Write-Output "                  [ 1 ] ==== APLICATIVOS"
        Write-Output "                  [ 2 ] ==== SISTEMA"
        Write-Output "                  [ 3 ] ==== REDE"
        Write-Output "                  [ 4 ] ==== UTILIARIOS"
        Write-Output "                  [ 0 ] ==== SAIR"
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
            "1" { Aplications }
            "2" { System }
            "3" { Network }
            "4" { Utilities }
            "0" { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
}

# Função para o menu de Aplicativos
function Aplications {
    $running = $true
    do {
        clear-Host
        Write-Output "================================================================"
        Write-Output "  	              MENU FERRAMENTAS DE APLICATIVOS"
        Write-Output "================================================================"
        Write-Output ""
        Write-Output "          [ 1 ]  = INSTALAR PROGRAMAS DO ARQUIVO TXT" 
        Write-Output "          [ 2 ]  = VERIFICAR PROGRAMAS INSTALADOS"
        Write-Output "          [ 3 ]  = ATUALIZAR PROGRAMAS INSTALADOS"
        Write-Output "          [ 4 ]  = SALVAR LISTA DOS INSTALADOS EM ARQUIVO"
        Write-Output "          [ 5 ]  = DESINSTALAR PROGRAMAS ESPECIFICOS"
        Write-Output "          [ 6 ]  = REPARAR PROGRAMAS INSTALADOS " 
        Write-Output "          [ 7 ]  = LIMPAR CACHE DE APLICATIVOS"
        Write-Output "          [ 8 ]  = VERIFICAR PROGRAMAS COM INICIAL AUTOMATICA"
        Write-Output "          [ 9 ]  = OTIMIZAR INICIALIZACAO DE PROGRAMAS"
        Write-Output "          [ 10 ] = VERIFICAR APLICATIVOS VULNERAVEIS"
        Write-Output "          [ 0 ]  = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
            "1"  { InstallAppsTxt }
            "2"  { CheckInstalledApps }
            "3"  { UpdateInstalledApps }
            "4"  { SaveInstalledAppsList }
            "5"  { UninstallSpecificApps }
            "6"  { RepairInstalledApps }
            "7"  { ClearAppCache }
            "8"  { CheckStartupApps }
            "9"  { OptimizeStartupApps }
            "10" { CheckVulnerableApps }
            "0"  { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
   
}

# Função para o menu de Systema
function System {
    $running = $true
    do {
        clear-Host
        Write-Output "================================================================"
        Write-Output "  	              MENU FERRAMENTAS DO SISTEMA"
        Write-Output "================================================================"
        Write-Output ""
        Write-Output "          [ 1 ] = VERIFICAR USO DE DISCO"
        Write-Output "          [ 2 ] = VERIFICAR USO DE MEMORIA"
        Write-Output "          [ 3 ] = VERIFICAR USO DE CPU"
        Write-Output "          [ 4 ] = LIMPAR ARQUIVOS TEMP"
        Write-Output "          [ 5 ] = LIMPEZA DE REGISTRO"
        Write-Output "          [ 6 ] = LIMPEZA DE DISCO "
        Write-Output "          [ 7 ] = CORRIGIR PROBLEMAS NO SISTEMA"
        Write-Output "          [ 8 ] = VERIFICAR INTEGRIDADE DO SISTEMA"
        Write-Output "          [ 9 ] = RESTAURAR INTEGRIDADE DO SISTEMA"
        Write-Output "          [ 0 ] = VOLTAR AO MENU PRINCIPAL " 
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
            "1" { check_disk_usage }
            "2" { check_memory_usage } 
            "3" { check_cpu_usage }
            "4" { clear_temp_files }
            "5" { check_system_services }
            "6" { disk_cleanup }
            "7" { fix_system_issues }
            "8" { check_system_integrity }
            "9" { restore_system_integrity}
            "0" { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
   
}

# Função para o menu de Rede
function Network {
    $running = $true
    do {
        clear-Host
        Write-Output "================================================================"
        Write-Output "  	              MENU FERRAMENTAS DE REDE"
        Write-Output "================================================================"
        Write-Output ""
        Write-Output "          [ 1 ]  = VERIFICAR CONEXÃO COM A INTERNET"
        Write-Output "          [ 2 ]  = VERIFICAR ENDEREÇO IP"
        Write-Output "          [ 3 ]  = VERIFICAR CONFIGURAÇÕES DE REDE"
        Write-Output "          [ 4 ]  = VERIFICAR USO DE LARGURA DE BANDA"
        Write-Output "          [ 5 ]  = VERIFICAR SERVIÇOS DE REDE"
        Write-Output "          [ 6 ]  = DEFINIR DNS PARA GOOGLE"
        Write-Output "          [ 7 ]  = DEFINIR DNS PARA CLOUDFARE"
        Write-Output "          [ 8 ]  = DEFINIR DNS PARA OPENDNS"
        Write-Output "          [ 9 ]  = ADICIONAR DNS PERSONALIZADO"
        Write-Output "          [ 10 ] = RESTAURAR DNS PARA PADRÃO"
        Write-Output "          [ 11 ] = REINICIAR ATAPTADORES DE REDE "
        Write-Output "          [ 0 ]  = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
            "1" { check_internet_connection }
            "2" { check_ip_address }
            "3" { check_network_config }
            "4" { check_bandwidth_usage }
            "5" { check_network_services }
            "6" { set_google_dns }
            "7" { set_cloudflare_dns }
            "8" { set_opendns }
            "9" { add_custom_dns }
            "10" { restore_default_dns }
            "11" { restart_network_adapters }
            "0"  { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
   
}

# Função para o menu de Utilitários
function Utilities {
    $running = $true
    do {
        clear-Host
        Write-Output "================================================================"
        Write-Output "  	              MENU FERRAMENTAS DE UTILITÁRIOS"
        Write-Output "================================================================"
        Write-Output ""
        Write-Output "          [ 1 ] = VERIFICAR USO DE DISCO"
        Write-Output "          [ 2 ] = VERIFICAR USO DE MEMÓRIA"
        Write-Output "          [ 3 ] = VERIFICAR USO DE CPU"
        Write-Output "          [ 4 ] = LIMPAR ARQUIVOS TEMP"
        Write-Output "          [ 5 ] = VERIFICAR SERVIÇOS DO SISTEMA"
        Write-Output "          [ 6 ] = LIMPEZA DE REGISTRO"
        Write-Output "          [ 7 ] = GERAR RELATORIO DO SISTEMA"
        Write-Output "          [ 8 ] = CRIAR PONTO DE RESTAURACAO"
        Write-Output "          [ 9 ] = CRIA USUARIO ADMINISTRADOR"
        Write-Output "          [ 10 ] = ATIVAR CONTA DE ADMINISTRADOR INTERNO"
        Write-Output "          [ 11 ] = DESATIVAR CONTA DE ADMINISTRADOR INTERNO"
        Write-Output "          [ 12 ] = ATIVAR MODO DE SEGURANCA"
        Write-Output "          [ 13 ] = ATIVAR HIRBERNAR"
        Write-Output "          [ 14 ] = DESATIVAR HIBERNAR"
        Write-Output "          [ 0 ]  = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
           "1" { check_disk_usage }
           "2" { check_memory_usage }
           "3" { check_cpu_usage }
           "4" { clear_temp_files }
           "5" { check_system_services }
           "6" { clean_registry }
           "7" { disk_cleanup }
           "8" { generate_system_report }
           "9" { create_admin_user }
           "10" { enable_builtin_admin }
           "11" { disable_builtin_admin }
           "12" { enable_safe_mode }
           "13" { enable_hibernation }
           "14" { disable_hibernation }
            "0"  { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
   
}
MainMenu