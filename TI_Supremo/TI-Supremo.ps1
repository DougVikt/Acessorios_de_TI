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
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(70, 500)
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(70, 40)

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

MainMenu