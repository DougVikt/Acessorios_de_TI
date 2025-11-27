
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


function UpdateUnistallApps {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Update','Uninstall')]
        [string]$Action
    )
    # Define título para o cabeçalho
    $title = if ($Action -eq 'Update') { 
        "ATUALIZANDO PROGRAMAS INSTALADOS" 
    }else { 
        "DESINSTALANDO PROGRAMAS ESPECIFICOS" 
    }
    # Define texto de ação
    $actionText = if ($Action -eq 'Update') { "atualiz" } else { "desinstal" }
    # Exibe cabeçalho
    FunctionHeader -title $title

    # Verifica winget e obtém lista de apps
    if (Checking_winget) { 
        $apps = VerifyApps
        if (-not $apps) { 
            Write-Warning "Nenhum programa encontrado."; 
            Read-Host "Enter"; 
            return 
        }
    }else {
        Write-Warning "Winget nao esta disponivel. Abortando."
        Read-Host "Enter"; return
    }    

    # Ajusta lista de apps com atualização 
    if ($Action -eq 'Update') {
        Write-Host "Verificando atualizacoes..." -ForegroundColor Cyan
        $upRaw = winget upgrade --accept-source-agreements | Out-String
        $updates = $upRaw -split "`n" | Where-Object { $_ -match '^\s*\d+' -or $_ -match '\.\w'} | ForEach-Object {
            $c = $_ -split '\s{2,}' -ne $null
            if ($c.Count -ge 5) {
                [pscustomobject]@{
                    Name      = $c[0].Trim()
                    ID        = $c[1].Trim()
                    Version   = $c[2].Trim()
                    Available = $c[3].Trim()
                    Source    = $c[4].Trim()
                }
            }
        }

        if (-not $updates) {
            Write-Host "Nenhum programa com atualizacoes disponiveis." -ForegroundColor Green
            Read-Host "Enter"; return
        }
        $apps = $updates   # a partir daqui $apps contém só os que podem ser atualizados
    }
        
    

    # ---------- Coluna numerada ----------
    $appsWithIdx = $apps | ForEach-Object -Begin { $i = 1 } -Process {
        $_ | Add-Member -NotePropertyName 'Num' -NotePropertyValue $i -PassThru
        $i++
    }

    # ---------- Exibição ----------
    Write-Host "Total de itens: $($apps.Count)" -ForegroundColor Magenta
    Write-Output ""
    Write-Host "Lista de Programas:" -ForegroundColor Yellow
    Write-Output ("-"*60)
    if ($Action -eq 'Update') {
        $appsWithIdx | Select-Object Num, Name, ID, Version, Available, Source | Format-Table -AutoSize | Out-Host
    } else {
        $appsWithIdx | Select-Object Num, Name, ID, Version, Source | Format-Table -AutoSize | Out-Host
    }

    # ---------- Selecao ----------
    if ($Action -eq 'Update') {
        $all = Read-Host "Atualizar TODOS os programas listados? (S/N) [N = escolher]"
        if ($all -match '^[SsYy]') { 
            $selectedIdx = 1..$apps.Count 
        }elseif ($all -match '^[Nn]') {
            $selectedIdx = $null
        }else {
            Write-Warning "Entrada invalida. Abortando."
            Read-Host "Enter para retornar "; 
            return
        }
    }
    if (-not $selectedIdx) {
        Write-Host "Digite os numeros que deseja $($actionText)ar (ex: 1,3,5 ou 1-3):" -ForegroundColor Cyan
        $sel = Read-Host "Selecao"
        $selectedIdx = @()
        foreach ($part in $sel -split ',') {
            if ($part -match '^\d+$') { $selectedIdx += [int]$part }
            elseif ($part -match '^(\d+)-(\d+)$') {
                $s,$e = $part -split '-'
                $selectedIdx += [int]$s..[int]$e
            }
        }
        $selectedIdx = $selectedIdx |
                       Where-Object { $_ -ge 1 -and $_ -le $apps.Count } |
                       Sort-Object -Unique
        if (-not $selectedIdx) { Write-Warning "Nenhuma selecao valida."; Read-Host "Enter"; return }
    }

    # ---------- Confirmação ----------
    $toDo = $appsWithIdx | Where-Object { $_.'Num' -in $selectedIdx }
    Write-Host "`nProgramas que serao $($actionText)ados:" -ForegroundColor Yellow
    if ($Action -eq 'Update') {
        $toDo | Format-Table -Property Num, Name, ID, Version, Available -AutoSize | Out-Host
    } else {
        $toDo | Format-Table -Property Num, Name, ID, Version -AutoSize | Out-Host
    }
    $ok = Read-Host "Confirma? (S/N)"
    if ($ok -notmatch '^[SsYy]') { 
        Write-Warning "Operacao cancelada."; 
        Read-Host "Enter para retornar "; 
        return 
    }

    # ---------- Execução ----------
    $success = 0; $fail = 0; $failed = @()
    foreach ($idx in $selectedIdx) {
        $app = $appsWithIdx[$idx-1]
        $appname = $app.Name
        $appId = $app.ID
        
        Write-Host "$($actionText)ando : $appname - $appId" -ForegroundColor White
        try {
            if ($Action -eq 'Update') {
                winget upgrade --id $appId --accept-source-agreements --accept-package-agreements
            } else {
                winget uninstall --id "$appId" --force --accept-source-agreements
                
            }

            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$appName] $($actionText)ado com sucesso." -ForegroundColor Green
                $success++
            } else {
                Write-Host "[$appName] Falhou (código: $LASTEXITCODE)." -ForegroundColor Red
                $fail++
                $failed += $appName
            }
        }
        catch {
            Write-Host "[$appName] Erro critico: $($_.Exception.Message)" -ForegroundColor Red
            $fail++
            $failed += $appName
        }

        Start-Sleep -Seconds 2  # Pequena pausa visual
}

    # ---------- Resumo ----------
    Write-Host "`n=== RESUMO ===" -ForegroundColor Magenta
    Write-Host "Sucesso: $success" -ForegroundColor Green
    Write-Host "Falha  : $fail"   -ForegroundColor Red
    if ($failed) { 
        Write-Host "Falharam:" -ForegroundColor Red; $failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red } 
    }

    Write-Output "`nPressione Enter para continuar."; Read-Host
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

function FunctionHeader {
    param (
        [string]$title
    )
    Clear-Host
    Write-Output ("="*65)
    Write-Output "               $title"
    Write-Output ("="*65)
    Write-Output ""
}

