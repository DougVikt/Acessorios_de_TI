
# Configurações para mostrar erros
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# Configurar log de erros
$ErrorLogPath = Join-Path $PSScriptRoot "errors.log"
New-Item -Path $ErrorLogPath -ItemType File -Force | Out-Null

# Trap para capturar erros e logar
trap {
    $errorMessage = $_.Exception.Message
    Add-Content -Path $ErrorLogPath -Value "$(Get-Date): $errorMessage"
    continue
}

# Abrir janela separada para mostrar erros em tempo real
$viewerScript = "Get-Content `"$ErrorLogPath`" -Wait"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $viewerScript

# ====================================================================================
#                           nício do script teste
# ====================================================================================

