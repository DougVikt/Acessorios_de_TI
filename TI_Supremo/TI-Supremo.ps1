# Define o título da janela do PowerShell
$Host.UI.RawUI.WindowTitle = "TI Supremo - Ferramenta do TI"

# Verifica se a sessão é Administrador
# if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
# {
#     # Se não for admin, relança o script com privilégios elevados
#     $argList = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
#     Start-Process powershell -Verb RunAs -ArgumentList $argList
#     exit
# }

# Função para exibir o menu principal
function MainMenu {
    $running = $true
    do {
        Clear-Host
        Write-Output "================================================"
        Write-Output "          FERRAMENTA SUPREMA DO TI"
        Write-Output "================================================"
        Write-Output ""
        Write-Output "        [ 1 ] ==== APLICATIVOS"
        Write-Output "        [ 2 ] ==== SISTEMA"
        Write-Output "        [ 3 ] ==== REDE"
        Write-Output "        [ 4 ] ==== UTILIARIOS"
        Write-Output "        [ 0 ] ==== SAIR"
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
            "1" { Aplicativos }
            "2" { Sistema }
            "3" { Rede }
            "4" { Utilitarios }
            "0" { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
}

function Aplicativos {
    clear-Host
    Write-Output "Funcionalidade de Aplicativos ainda não implementada."
    Pause
}

MainMenu