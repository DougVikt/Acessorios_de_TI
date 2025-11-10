
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
#                           início do script teste
# ====================================================================================

# Função para atualizar programas instalados
function UpdateInstalledApps {
    Clear-Host
    Write-Output "================================================================"
    Write-Output "              ATUALIZANDO PROGRAMAS INSTALADOS"
    Write-Output "================================================================"
    Write-Output ""

    # Verifica se o winget está disponível
    if (Checking_winget) {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Coletando lista de programas instalados e verificando atualizacoes..." -ForegroundColor Cyan
            try {
                $app = VerifyApps

                # Obtém a lista de atualizações disponíveis
                $upgradableApps = winget upgrade --accept-source-agreements | Out-String
                $updates = $upgradableApps -split "`n" | Where-Object { $_ -match "^\S" } | ForEach-Object {
                    $columns = $_ -split "\s{2,}"
                    if ($columns.Count -ge 5) {
                        [PSCustomObject]@{
                            Name        = $columns[0].Trim()
                            ID          = $columns[1].Trim()
                            Version     = $columns[2].Trim()
                            Available   = $columns[3].Trim()
                            Source      = $columns[4].Trim()
                        }
                    }
                }

                if ($updates.Count -eq 0) {
                    Write-Host "Nenhum programa com atualizacoes disponiveis." -ForegroundColor Green
                    Write-Output "Pressione Enter para continuar."; Read-Host
                    return
                }

                # Adiciona uma coluna numerada para exibição
                $updatesWithIndex = $updates | ForEach-Object -Begin { $index = 1 } -Process {
                    $_ | Add-Member -MemberType NoteProperty -Name "Nun" -Value $index -PassThru
                    $index++
                }

                Write-Host "Total de programas com atualizacoes disponiveis: $($updates.Count)" -ForegroundColor Magenta
                Write-Output ""
                Write-Host "Lista de Atualizacoes Disponiveis:" -ForegroundColor Yellow
                Write-Output "------------------------------------------------------------"
                $updatesWithIndex | Format-Table -Property "Nun", Name, ID, Version, Available, Source -AutoSize | Out-Host

                # Pergunta se o usuário quer atualizar todos ou selecionar
                $updateChoice = Read-Host "Deseja atualizar todos os programas listados? (S/N) [N para selecionar especificos]"
                if ($updateChoice -match '^[SsYy]') {
                    # Atualiza todos os programas
                    Write-Host "Atualizando todos os programas..." -ForegroundColor Cyan
                    $successCount = 0
                    $failCount = 0
                    $failedApps = @()
                    foreach ($app in $updates) {
                        Write-Host "Atualizando: $($app.Name) ($($app.ID))" -ForegroundColor White
                        try {
                            winget upgrade --id $app.ID --silent --accept-package-agreements --accept-source-agreements
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "$($app.Name) atualizado com sucesso para a versao $($app.Available)" -ForegroundColor Green
                                $successCount++
                            } else {
                                Write-Host "Falha ao atualizar $($app.Name)" -ForegroundColor Red
                                $failCount++
                                $failedApps += $app.Name
                            }
                        } catch {
                            Write-Host "Erro ao atualizar $($app.Name): $($_.Exception.Message)" -ForegroundColor Red
                            $failCount++
                            $failedApps += $app.Name
                        }
                        Start-Sleep -Seconds 2
                    }

                    # Resumo da atualização
                    Write-Host "=== RESUMO DA ATUALIZACAO ===" -ForegroundColor Magenta
                    Write-Host "Programas atualizados com sucesso: $successCount" -ForegroundColor Green
                    Write-Host "Programas com falha: $failCount" -ForegroundColor Red
                    if ($failedApps.Count -gt 0) {
                        Write-Host "Programas que falharam:" -ForegroundColor Red
                        $failedApps | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
                    }
                } else {
                    # Seleção de aplicativos específicos
                    Write-Host "Digite os numeros dos programas que deseja atualizar `n EX: 2,3,5 para individual ou 2-4 para intervalos" -ForegroundColor Yellow
                    $selection = Read-Host "Selecao"
                    $selectedIndices = @()
                    # Processa a seleção do usuário permitindo múltiplos formatos
                    foreach ($item in $selection -split ',') {
                        if ($item -match '^\d+$') {
                            $selectedIndices += [int]$item
                        } elseif ($item -match '^(\d+)-(\d+)$') {
                            $start, $end = $item -split '-'
                            $selectedIndices += [int]$start..[int]$end
                        }
                    }
                    # Filtra índices inválidos e remove duplicatas
                    $selectedIndices = $selectedIndices | Where-Object { $_ -ge 1 -and $_ -le $updates.Count } | Sort-Object -Unique

                    if ($selectedIndices.Count -eq 0) {
                        Write-Warning "Nenhuma selecao valida. Cancelando atualizacao."
                        Write-Output "Pressione Enter para continuar."; Read-Host
                        return
                    }

                    # Atualiza os programas selecionados
                    Write-Host "Atualizando programas selecionados..." -ForegroundColor Cyan
                    $successCount = 0
                    $failCount = 0
                    $failedApps = @()
                    # Itera sobre os índices selecionados
                    foreach ($index in $selectedIndices) {
                        $app = $updatesWithIndex[$index - 1]
                        Write-Host "Atualizando: $($app.Name) ($($app.ID))" -ForegroundColor White
                        # Tenta atualizar o aplicativo e captura erros
                        try {
                            winget upgrade --id $app.ID --silent --accept-package-agreements --accept-source-agreements
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "$($app.Name) atualizado com sucesso para a versao $($app.Available)" -ForegroundColor Green
                                $successCount++
                            } else {
                                Write-Host "Falha ao atualizar $($app.Name)" -ForegroundColor Red
                                $failCount++
                                $failedApps += $app.Name
                            }
                        } catch {
                            Write-Host "Erro ao atualizar $($app.Name): $($_.Exception.Message)" -ForegroundColor Red
                            $failCount++
                            $failedApps += $app.Name
                        }
                        Start-Sleep -Seconds 2
                    }

                    # Resumo da atualização
                    Write-Host "=== RESUMO DA ATUALIZAÇÃO ===" -ForegroundColor Magenta
                    Write-Host "Programas atualizados com sucesso: $successCount" -ForegroundColor Green
                    Write-Host "Programas com falha: $failCount" -ForegroundColor Red
                    if ($failedApps.Count -gt 0) {
                        Write-Host "Programas que falharam:" -ForegroundColor Red
                        $failedApps += $app.Name
                        $failedApps | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
                    }
                }

                # Opção para salvar o log de atualizações
                $logChoice = Read-Host "Deseja salvar um log das atualizacoes em um arquivo TXT? (S/N)"
                if ($logChoice -match '^[SsYy]') {
                    $scriptDirectory = Get-ScriptDirectory
                    $logPath = Join-Path -Path $scriptDirectory -ChildPath "update_log_$(Get-Date -Format 'dd_MM_yyyy').txt"
                    try {
                        "# Log de atualizacoes gerado em $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')" | Out-File -FilePath $logPath -Encoding UTF8 -ErrorAction Stop
                        "# Formato: N° | Nome | ID | Versao Atual | Versao Disponivel" | Out-File -FilePath $logPath -Append -Encoding UTF8
                        $index = 1
                        $updates | ForEach-Object {
                            "# $index | $($_.Name) | $($_.ID) | $($_.Version) | $($_.Available)" | Out-File -FilePath $logPath -Append -Encoding UTF8
                            $index++
                        }
                        Write-Host "Log de atualizacoes salvo em: $logPath" -ForegroundColor Green
                    } catch {
                        Write-Warning "Erro ao salvar o log de atualizacoes: $($_.Exception.Message)"
                    }
                }
            } catch {
                Write-Warning "Erro ao verificar programas instalados ou atualizacoes: $($_.Exception.Message)"
            }
        } else {
            Write-Warning "Winget nao encontrado. Nao e possivel listar ou atualizar programas."
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
        Write-Warning "Nao foi possivel obter o diretorio do script: $($_.Exception.Message)"
        # Fallback para a área de trabalho do usuário
        $scriptDirectory = [Environment]::GetFolderPath("Desktop")
        Write-Host "Usando a area de trabalho como diretorio padrao: $scriptDirectory" -ForegroundColor Yellow
    }

    # Verifica se o diretório existe
    if (-not (Test-Path $scriptDirectory)) {
        Write-Warning "Diretorio nao encontrado: $scriptDirectory. Salvando na area de trabalho."
        $scriptDirectory = [Environment]::GetFolderPath("Desktop")
    }
    return $scriptDirectory
}

function VerifyApps{
     # Obtém a lista de programas instalados
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
    } else {
        return $apps
    }
}



UpdateInstalledApps