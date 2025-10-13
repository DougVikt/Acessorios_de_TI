
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

function CheckInstalledApps {
    Clear-Host
    Write-Output "================================================================"
    Write-Output "              VERIFICANDO PROGRAMAS INSTALADOS"
    Write-Output "================================================================"
    Write-Output ""

    # Verifica se o winget está disponível
    if (Checking_winget) {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Coletando lista de programas instalados..." -ForegroundColor Cyan
            try {
                # Executa o comando winget list para obter os programas instalados
                $installedApps = winget list --accept-source-agreements | Out-String
                $apps = $installedApps -split "`n" | Where-Object { $_ -match "^\S" } | ForEach-Object {
                    $columns = $_ -split "\s{2,}"
                    if ($columns.Count -ge 4) {
                        [PSCustomObject]@{
                            Name    = $columns[0].Trim()
                            ID      = $columns[1].Trim()
                            Version = $columns[2].Trim()
                            Source  = $columns[3].Trim()
                        }
                    }
                }

                if ($apps.Count -eq 0) {
                    Write-Warning "Nenhum programa encontrado."
                    Write-Output "Pressione Enter para continuar."; Read-Host
                    return
                }
                 # Adiciona uma coluna numerada para exibição
                $appsWithIndex = $apps | ForEach-Object -Begin { $index = 1 } -Process {
                    $_ | Add-Member -MemberType NoteProperty -Name "Nº" -Value $index -PassThru
                    $index++
                }
                
                Write-Host "Total de programas instalados: $($apps.Count)" -ForegroundColor Magenta
                Write-Output ""
                Write-Host "Lista de Programas Instalados:" -ForegroundColor Yellow
                Write-Output "------------------------------------------------------------"
                $appsWithIndex | Format-Table -Property "Nº", Name, ID, Version, Source -AutoSize | Out-Host

                # Opção para salvar a lista
                $saveChoice = Read-Host "Deseja salvar a lista em um arquivo? (S/N)"
                if ($saveChoice -match '^[SsYy]') {
                    # Obtém o diretório do script atual
                    $scriptDirectory = Get-ScriptDirectory
                    $filePath = Join-Path -Path $scriptDirectory -ChildPath "installed_apps_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                    try {
                        # Adiciona um comentário inicial e informações detalhadas como comentários
                        "# Lista de aplicativos instalados gerada em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $filePath -Encoding UTF8 -ErrorAction Stop
                        "# Formato: ID , Versao" | Out-File -FilePath $filePath -Append -Encoding UTF8
                        $apps | ForEach-Object {
                            "$($_.ID),$($_.Version)" | Out-File -FilePath $filePath -Append -Encoding UTF8
                        }
                        Write-Host "Lista de IDs com detalhes salva em: $filePath" -ForegroundColor Green
                    } catch {
                        Write-Warning "Erro ao salvar o arquivo TXT: $($_.Exception.Message)"
                    }
                }
            } catch {
                Write-Warning "Erro ao verificar programas instalados: $($_.Exception.Message)"
            }
        } else {
            Write-Warning "Winget nao encontrado. Nao e possivel listar os programas."
        }
    } else {
        Write-Warning "Falha ao verificar ou instalar o Winget."
    }
    Write-Output ""
    Write-Output "Pressione Enter para continuar."; Read-Host
}
function Checking_winget {
    try {
        # Verifica se o comando winget está disponível
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Winget verificado."
            return $true
        }
        else {
            Write-Warning "Winget nao encontrado. Tentando instalar...`n"
            
            # Tenta instalar o módulo Microsoft.WinGet.Client via PowerShell Gallery
            Install-PackageProvider -Name NuGet -Force -ErrorAction Stop | Out-Null
            Install-Module -Name Microsoft.WinGet.Client -Force -ErrorAction Stop | Out-Null

            # Usa Repair para garantir instalação finalizada
            Repair-WinGetPackageManager -AllUsers -ErrorAction Stop

            Write-Host "Winget instalado com sucesso." -ForegroundColor Yellow
            return $true
        }
    }catch {
        # Trata erros de instalação
        Write-Warning "Erro ao verificar ou instalar Winget: $($_.Exception.Message)" 
        return $false
    }
}

# FUNÇÃO PARA VERRIFICAR O DIRETORIO DO SCRIPT
function Get-ScriptDirectory {
    # Tenta obter o diretório do script atual
    try {
        $scriptDirectory = Split-Path -Path $PSCommandPath -Parent -ErrorAction Stop
    } catch {
        Write-Warning "Não foi possível obter o diretório do script: $($_.Exception.Message)"
        # Fallback para a área de trabalho do usuário
        $scriptDirectory = [Environment]::GetFolderPath("Desktop")
        Write-Host "Usando a área de trabalho como diretório padrão: $scriptDirectory" -ForegroundColor Yellow
    }

    # Verifica se o diretório existe
    if (-not (Test-Path $scriptDirectory)) {
        Write-Warning "Diretório não encontrado: $scriptDirectory. Salvando na área de trabalho."
        $scriptDirectory = [Environment]::GetFolderPath("Desktop")
    }
    return $scriptDirectory
}
CheckInstalledApps