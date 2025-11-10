# Define o título da janela do PowerShell
$Host.UI.RawUI.WindowTitle = "TI Supremo - Ferramenta do TI"
# Configurar cores do console
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"
# define o tamanho da janela do PowerShell
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(65, 40)

# Verifica se a sessão é Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    # Se não for admin, relança o script com privilégios elevados
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process powershell -Verb RunAs -ArgumentList $argList
    exit
}
# =============================== FUNÇÃO PRINCIPAL ================================
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
# ============================= FUNÇÕES DE APLICATIVOS ===============================
# Função para o menu principal de Aplicativos
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
        Write-Output "          [ 4 ]  = DESINSTALAR PROGRAMAS ESPECIFICOS"
        Write-Output "          [ 5 ]  = REPARAR PROGRAMAS INSTALADOS " 
        Write-Output "          [ 6 ]  = LIMPAR CACHE DE APLICATIVOS"
        Write-Output "          [ 7 ]  = VERIFICAR PROGRAMAS COM INICIAL AUTOMATICA"
        Write-Output "          [ 8 ]  = OTIMIZAR INICIALIZACAO DE PROGRAMAS"
        Write-Output "          [ 9 ] = VERIFICAR APLICATIVOS VULNERAVEIS"
        Write-Output "          [ 0 ]  = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        # Solicita a escolha do usuário
        $choice = Read-Host "  Escolha uma opcao "

        # Chama a função correspondente à escolha do usuário
        switch ($choice) {
            "1"  { InstallAppsTxt }
            "2"  { CheckInstalledApps }
            "3"  { UpdateInstalledApps }
            "4"  { UninstallSpecificApps }
            "5"  { RepairInstalledApps }
            "6"  { ClearAppCache }
            "7"  { CheckStartupApps }
            "8"  { OptimizeStartupApps }
            "9" { CheckVulnerableApps }
            "0"  { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
    
}

# Função para instalar aplicativos a partir de um arquivo apps.txt
function InstallAppsTxt{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Force = $false
    )
     Clear-Host
    Write-Output "================================================================"
    Write-Output "              PROGRAMAS INSTALADOS VIA ARQUIVO TXT"
    Write-Output "================================================================"
    Write-Output ""
    Write-Output " Verifique se o arquivo apps.txt está no mesmo diretório do script e contém os IDs corretos dos aplicativos."
    Write-Output " Ex: # Navegadores"
    Write-Output "      Google.Chrome"
    # Obtém o diretório do script atual
    $scriptDirectory = Get-ScriptDirectory  
    # Inicializa a contagem de tentativas 
    $attempt_count = 0
    # Verifica se o arquivo existe
    do{ 
        clear-Host
        # Solicita o nome do arquivo txt
        $FileName = Read-Host "Digite o nome do arquivo txt (ex: apps.txt)"
        # Cria o caminho completo do arquivo txt
        $FilePath = Join-Path -Path $scriptDirectory -ChildPath $FileName
        if (-not (Test-Path $FilePath)) {
            Write-Warning "Arquivo não encontrado: $FilePath"
            Write-Warning "Por favor, verifique o nome do arquivo e tente novamente.";Read-Host
            $attempt_count++
        }    
        # Verifica se é um arquivo .txt
        elseif ((Get-Item $FilePath).Extension -ne ".txt") {
            Write-Warning "O arquivo especificado não é um arquivo de texto(.txt)"
            Write-Warning "Por favor, forneça um arquivo .txt válido.";Read-Host
            $attempt_count++            
        }
        if($attempt_count -ge 5){
            Write-Warning "Muitas tentativas sem exito , verifique se o arquivo exite e terminado em .txt." 
            Write-Warning "Saindo da função...."
            return
        }
    }while(-not (Test-Path $FilePath) -or (Get-Item $FilePath).Extension -ne ".txt")
        Clear-Host
        Write-Output "Arquivo encontrado: $FilePath"
    
    # Ler o arquivo e processa cada linha
    $apps = Get-Content $FilePath | Where-Object { 
        $_.Trim() -ne "" -and $_.Trim() -notlike "#*" 
    }
    
    if ($apps.Count -eq 0) {
        Write-Warning "Nenhum aplicativo encontrado no arquivo $FilePath"
        return
    }
    
    Write-Host "Encontrados $($apps.Count) aplicativos para instalação:" -ForegroundColor Magenta
    $apps | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host ""
    
    # Confirmar instalação
    if (-not $Force) {
        $confirmation = Read-Host "Deseja prosseguir com a instalação? (S/N)"
        if ($confirmation -notmatch '^[SsYy]') {
            Write-Host "Instalação cancelada." -ForegroundColor Red
            return
        }
    }
    
    $successCount = 0
    $failCount = 0
    $failedApps = @()
    
    # Instalar usando Winget
    if (Checking_winget) {
        # Verificar se winget está disponível
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Instalando aplicativos usando Winget..." -ForegroundColor Cyan
            
            foreach ($app in $apps) {
                Write-Host "Instalando: $app" -ForegroundColor White
                
                try {
                    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "$app instalado com sucesso" -ForegroundColor Green
                        $successCount++
                    } else {
                        Write-Host "Falha ao instalar $app" -ForegroundColor Red
                        $failCount++
                        $failedApps += $app
                    }
                }catch {
                    Write-Host "Erro ao instalar $app : $($_.Exception.Message)" -ForegroundColor Red
                    $failCount++
                    $failedApps += $app
                }
                Start-Sleep -Seconds 2  # Pequena pausa entre instalações
            }
        } else {
            Write-Warning "Winget não encontrado. Pulando instalação via Winget."
        }
    
    }
    
    # Resumo da instalação
    Write-Host "=== RESUMO DA INSTALAÇÃO ===" -ForegroundColor Magenta
    Write-Host "Aplicativos instalados com sucesso: $successCount" -ForegroundColor Green
    Write-Host "Aplicativos com falha: $failCount" -ForegroundColor Red
    
    if ($failedApps.Count -gt 0) {
        Write-Host "Aplicativos que falharam na instalação:" -ForegroundColor Red
        $failedApps | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
}

# Função para verificar programas instalados
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
                $apps = VerifyApps
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
                    $filePath = Join-Path -Path $scriptDirectory -ChildPath "installed_apps_$(Get-Date -Format 'dd_MM_yyyy').txt"
                    try {
                        # Adiciona um comentário inicial e informações detalhadas como comentários
                        "# Lista de aplicativos instalados gerada em $(Get-Date -Format 'dd_MM_yyyy HH:mm:ss')" | Out-File -FilePath $filePath -Encoding UTF8 -ErrorAction Stop
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
            Write-Host "Coletando lista de programas instalados e verificando atualizações..." -ForegroundColor Cyan
            try {
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
                }

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
                    Write-Host "Nenhum programa com atualizações disponíveis." -ForegroundColor Green
                    Write-Output "Pressione Enter para continuar."; Read-Host
                    return
                }

                # Adiciona uma coluna numerada para exibição
                $updatesWithIndex = $updates | ForEach-Object -Begin { $index = 1 } -Process {
                    $_ | Add-Member -MemberType NoteProperty -Name "Nº" -Value $index -PassThru
                    $index++
                }

                Write-Host "Total de programas com atualizações disponíveis: $($updates.Count)" -ForegroundColor Magenta
                Write-Output ""
                Write-Host "Lista de Atualizações Disponíveis:" -ForegroundColor Yellow
                Write-Output "------------------------------------------------------------"
                $updatesWithIndex | Format-Table -Property "Nº", Name, ID, Version, Available, Source -AutoSize | Out-Host

                # Pergunta se o usuário quer atualizar todos ou selecionar
                $updateChoice = Read-Host "Deseja atualizar todos os programas listados? (S/N) [N para selecionar específicos]"
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
                                Write-Host "$($app.Name) atualizado com sucesso para a versão $($app.Available)" -ForegroundColor Green
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
                        $failedApps | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
                    }
                } else {
                    # Seleção de aplicativos específicos
                    Write-Host "Digite os números (Nº) dos programas que deseja atualizar (ex: 1,3,5 ou 1-3):"
                    $selection = Read-Host "Seleção"
                    $selectedIndices = @()
                    foreach ($item in $selection -split ',') {
                        if ($item -match '^\d+$') {
                            $selectedIndices += [int]$item
                        } elseif ($item -match '^(\d+)-(\d+)$') {
                            $start, $end = $item -split '-'
                            $selectedIndices += [int]$start..[int]$end
                        }
                    }
                    $selectedIndices = $selectedIndices | Where-Object { $_ -ge 1 -and $_ -le $updates.Count } | Sort-Object -Unique

                    if ($selectedIndices.Count -eq 0) {
                        Write-Warning "Nenhuma seleção válida. Cancelando atualização."
                        Write-Output "Pressione Enter para continuar."; Read-Host
                        return
                    }

                    # Atualiza os programas selecionados
                    Write-Host "Atualizando programas selecionados..." -ForegroundColor Cyan
                    $successCount = 0
                    $failCount = 0
                    $failedApps = @()
                    foreach ($index in $selectedIndices) {
                        $app = $updatesWithIndex[$index - 1]
                        Write-Host "Atualizando: $($app.Name) ($($app.ID))" -ForegroundColor White
                        try {
                            winget upgrade --id $app.ID --silent --accept-package-agreements --accept-source-agreements
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "$($app.Name) atualizado com sucesso para a versão $($app.Available)" -ForegroundColor Green
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
                $logChoice = Read-Host "Deseja salvar um log das atualizações em um arquivo TXT? (S/N)"
                if ($logChoice -match '^[SsYy]') {
                    $scriptDirectory = Get-ScriptDirectory
                    $logPath = Join-Path -Path $scriptDirectory -ChildPath "update_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                    try {
                        "# Log de atualizações gerado em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logPath -Encoding UTF8 -ErrorAction Stop
                        "# Formato: Nº | Nome | ID | Versão Atual | Versão Disponível" | Out-File -FilePath $logPath -Append -Encoding UTF8
                        $index = 1
                        $updates | ForEach-Object {
                            "# $index | $($_.Name) | $($_.ID) | $($_.Version) | $($_.Available)" | Out-File -FilePath $logPath -Append -Encoding UTF8
                            $index++
                        }
                        Write-Host "Log de atualizações salvo em: $logPath" -ForegroundColor Green
                    } catch {
                        Write-Warning "Erro ao salvar o log de atualizações: $($_.Exception.Message)"
                    }
                }
            } catch {
                Write-Warning "Erro ao verificar programas instalados ou atualizações: $($_.Exception.Message)"
            }
        } else {
            Write-Warning "Winget não encontrado. Não é possível listar ou atualizar programas."
        }
    } else {
        Write-Warning "Falha ao verificar ou instalar o Winget."
    }
    Write-Output ""
    Write-Output "Pressione Enter para continuar."; Read-Host
}

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

# ============================= FUNÇÕES DE SISTEMA ===================================
# Função para o menu principal de Systema
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

# ============================= FUNÇÕES DE REDE ======================================
# Função para o menu principal de Rede
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

# ============================= FUNÇÕES DE UTILITARIOS ===============================
# Função para o menu principal de Utilitários
function Utilities {
    $running = $true
    do {
        clear-Host
        Write-Output "================================================================"
        Write-Output "  	              MENU FERRAMENTAS DE UTILITARIOS"
        Write-Output "================================================================"
        Write-Output ""
        Write-Output "          [ 1 ] = VERIFICAR USO DE DISCO"
        Write-Output "          [ 2 ] = VERIFICAR USO DE MEMORIA"
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
        write-Output "          [ 15 ] = DESATIVAR MODO DE SEGURANCA"
        write-Output "          [ 16 ] = DETALHES DO HARDWARE"
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
            "15" { disable_safe_mode }
            "16" { hardware_details }
            "0"  { $running = $false }
            default { Write-Output "Opcao invalida. Pressione Enter para tentar novamente."; Read-Host }
        }
    } while ($running)
}



# =============================== FUNÇÕES GLOBAIS ===================================
# FUNÇÃO PARA VERIFICAR E INSTALAR WINGET
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

# FUNÇÃO PARA VERIFICAR A LISTA DE PROGRAMAS INSTALADOS
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


MainMenu