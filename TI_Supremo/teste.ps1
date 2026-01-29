
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


function Get-StartupAppManagement {   
    # Obtém os itens de inicialização do registro (HKCU e HKLM)
    $startupItems = @()
    # Exibe cabeçalho
    FunctionHeader -title "GERENCIAR APLICATIVOS DE INICIALIZACAO"
    
    # Itens do usuário atual (HKCU)
    $hkcuPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    try {
        if (Test-Path $hkcuPath) {
            $hkcuItems = Get-ItemProperty -Path $hkcuPath -ErrorAction Stop
            $hkcuItems.PSObject.Properties | Where-Object { $_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName" -and $_.Name -ne "PSDrive" -and $_.Name -ne "PSProvider" } | ForEach-Object {
                $startupItems += [PSCustomObject]@{
                    Nome = $_.Name
                    Comando = $_.Value
                    Local = "HKCU"
                    Caminho = $hkcuPath
                }
            }
        }
    } catch {
        Write-Host "Erro ao acessar itens de inicializacao do usuario (HKCU): $($_.Exception.Message)"
    }
    
    # Itens do sistema (HKLM)
    $hklmPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
    try {
        if (Test-Path $hklmPath) {
            $hklmItems = Get-ItemProperty -Path $hklmPath -ErrorAction Stop
            $hklmItems.PSObject.Properties | Where-Object { $_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName" -and $_.Name -ne "PSDrive" -and $_.Name -ne "PSProvider" } | ForEach-Object {
                $startupItems += [PSCustomObject]@{
                    Name = $_.Name
                    Command = $_.Value
                    Local = "HKLM"
                }
            }
        }
    } catch {
        Write-Host "Erro ao acessar itens de inicializacao do sistema (HKLM): $($_.Exception.Message)"
    }
    
    # Verifica se há itens
    if ($startupItems.Count -eq 0) {
        Write-Host "Nenhum aplicativo encontrado na inicializacao."
        return
    }
    
    $itemsInTable = $startupItems | ForEach-Object -Begin { $num = 1 } -Process {
        $_ | Add-Member -NotePropertyName 'Num' -NotePropertyValue $num -PassThru
        $num++
    }
    # Exibe os itens na tela
    $itemsInTable | Select-Object Num, Nome | Format-Table -AutoSize | Out-Host
    # Pergunta ao usuário
    try {
        $opcao = Read-Host "Digite 'todos' para remover todos,`n'selecionar' para escolher quais remover, ou 'nenhum' para sair"
    } catch {
        Write-Host "Erro ao ler entrada do usuario: $($_.Exception.Message)"
        return
    }
    
    if ($opcao -eq "todos") {
        # Remove todos
        foreach ($item in $startupItems) {
            try {
                Remove-ItemProperty -Path $item.Caminho -Name $item.Nome -ErrorAction Stop
                Write-Host "Removido: $($item.Nome)"
            } catch {
                Write-Host "Erro ao remover $($item.Nome): $($_.Exception.Message)"
            }
        }
    } elseif ($opcao -eq "selecionar") {
        # Permite escolher quais remover
        try {
            $indices = Read-Host "Digite os números dos itens a remover (separados por vírgula, ex: 1,3,5)"
        } catch {
            Write-Host "Erro ao ler entrada do usuário: $($_.Exception.Message)"
            return
        }
        $indicesArray = $indices -split "," | ForEach-Object { [int]$_.Trim() - 1 } | Where-Object { $_ -ge 0 -and $_ -lt $startupItems.Count }
        
        foreach ($index in $indicesArray) {
            $item = $startupItems[$index]
            try {
                Remove-ItemProperty -Path $item.Caminho -Name $item.Nome -ErrorAction Stop
                Write-Host "Removido: $($item.Nome)"
            } catch {
                Write-Host "Erro ao remover $($item.Nome): $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "Nenhuma ação realizada."
    }
}# não muito completa mas funciona 


function Remove-StartupApps {
   
    [CmdletBinding()]
    param()
    
    # Arrays para armazenar os apps de inicialização
    $startupApps = @()
    $index = 1
    
    Write-Host "`n=== APLICATIVOS DE INICIALIZAÇÃO DO SISTEMA ===`n" -ForegroundColor Cyan
    
    # 1. Verificar pasta de inicialização do usuário atual
    $userStartupPath = [Environment]::GetFolderPath('Startup')
    Write-Host "`n[Pasta de Inicialização do Usuário]" -ForegroundColor Yellow
    
    if (Test-Path $userStartupPath) {
        $shortcuts = Get-ChildItem -Path $userStartupPath -Filter *.lnk -ErrorAction SilentlyContinue
        
        foreach ($shortcut in $shortcuts) {
            $shell = New-Object -ComObject WScript.Shell
            $link = $shell.CreateShortcut($shortcut.FullName)
            
            $app = [PSCustomObject]@{
                Index     = $index
                Nome      = $shortcut.Name -replace '\.lnk$', ''
                Caminho   = $link.TargetPath
                Tipo      = "Pasta Usuário"
                Local     = $shortcut.FullName
                IsLink    = $true
            }
            $startupApps += $app
            $index++
        }
    }
    
    # 2. Verificar pasta de inicialização de todos os usuários
    $allUsersStartupPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    Write-Host "`n[Pasta de Inicialização de Todos os Usuários]" -ForegroundColor Yellow
    
    if (Test-Path $allUsersStartupPath) {
        $shortcuts = Get-ChildItem -Path $allUsersStartupPath -Filter *.lnk -ErrorAction SilentlyContinue
        
        foreach ($shortcut in $shortcuts) {
            $shell = New-Object -ComObject WScript.Shell
            $link = $shell.CreateShortcut($shortcut.FullName)
            
            $app = [PSCustomObject]@{
                Index     = $index
                Nome      = $shortcut.Name -replace '\.lnk$', ''
                Caminho   = $link.TargetPath
                Tipo      = "Pasta Todos Usuários"
                Local     = $shortcut.FullName
                IsLink    = $true
            }
            $startupApps += $app
            $index++
        }
    }
    
    # 3. Verificar registro do Windows (HKCU - Usuário atual)
    Write-Host "`n[Registro - Usuário Atual (HKCU)]" -ForegroundColor Yellow
    $regPathUser = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    
    if (Test-Path $regPathUser) {
        $regEntries = Get-ItemProperty -Path $regPathUser
        
        foreach ($entry in $regEntries.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"}) {
            $app = [PSCustomObject]@{
                Index     = $index
                Nome      = $entry.Name
                Caminho   = $entry.Value
                Tipo      = "Registro Usuário"
                Local     = $regPathUser
                IsLink    = $false
            }
            $startupApps += $app
            $index++
        }
    }
    
    # 4. Verificar registro do Windows (HKLM - Máquina)
    Write-Host "`n[Registro - Máquina (HKLM)]" -ForegroundColor Yellow
    $regPathMachine = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
    
    if (Test-Path $regPathMachine) {
        $regEntries = Get-ItemProperty -Path $regPathMachine
        
        foreach ($entry in $regEntries.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"}) {
            $app = [PSCustomObject]@{
                Index     = $index
                Nome      = $entry.Name
                Caminho   = $entry.Value
                Tipo      = "Registro Máquina"
                Local     = $regPathMachine
                IsLink    = $false
            }
            $startupApps += $app
            $index++
        }
    }
    
    # 5. Verificar serviços que iniciam automaticamente
    Write-Host "`n[Serviços de Inicialização Automática]" -ForegroundColor Yellow
    $services = Get-Service | Where-Object {$_.StartType -eq 'Automatic'} | Select-Object -First 10
    
    foreach ($service in $services) {
        $app = [PSCustomObject]@{
            Index     = $index
            Nome      = $service.Name
            Caminho   = $service.DisplayName
            Tipo      = "Serviço Automático"
            Local     = "Services"
            IsLink    = $false
        }
        $startupApps += $app
        $index++
    }
    
    # Mostrar todos os apps encontrados
    if ($startupApps.Count -eq 0) {
        Write-Host "`nNenhum aplicativo de inicialização encontrado." -ForegroundColor Green
        return
    }
    
    Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
    Write-Host "LISTA DE APLICATIVOS NA INICIALIZAÇÃO ($($startupApps.Count) encontrados):" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Cyan
    
    foreach ($app in $startupApps) {
        $color = if ($app.Tipo -like "*Usuário*") { "Green" } 
                elseif ($app.Tipo -like "*Máquina*") { "Yellow" }
                elseif ($app.Tipo -like "*Todos*") { "Magenta" }
                else { "White" }

        Write-Host ("[{0:00}] {1}" -f $app.Index, $app.Nome) -ForegroundColor $color -NoNewline
        Write-Host " - $($app.Tipo)" -ForegroundColor Gray
        Write-Host "   Caminho: $($app.Caminho)" -ForegroundColor DarkGray
        if ($app.Tipo -like "*Serviço*") {
            Write-Host "   Tipo: Serviço do Windows (use 'services.msc' para gerenciar)" -ForegroundColor DarkCyan
        }
    }
    
    Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
    
    # Menu de opções
    Write-Host "`nOPÇÕES:" -ForegroundColor Yellow
    Write-Host "1. Remover um aplicativo específico"
    Write-Host "2. Remover todos os aplicativos (excluindo serviços)"
    Write-Host "3. Sair"
    
    do {
        $opcao = Read-Host "`nDigite sua escolha (1-3)"
    } while ($opcao -notmatch '^[1-3]$')
    
    switch ($opcao) {
        "1" {
            # Remover aplicativo específico
            do {
                $appIndex = Read-Host "`nDigite o número do aplicativo para remover (1-$($startupApps.Count)) ou 0 para cancelar"
                
                if ($appIndex -eq "0") {
                    Write-Host "Operação cancelada." -ForegroundColor Yellow
                    return
                }
                
                $selectedApp = $startupApps | Where-Object {$_.Index -eq [int]$appIndex}
                
                if (-not $selectedApp) {
                    Write-Host "Número inválido. Tente novamente." -ForegroundColor Red
                }
            } while (-not $selectedApp)
            
            # Verificar permissões para itens do registro
            if (($selectedApp.Tipo -like "*Registro*" -or $selectedApp.Tipo -like "*Todos*") -and -not $isAdmin) {
                Write-Host "`nAVISO: Para remover itens do registro ou da pasta Todos Usuários," -ForegroundColor Yellow
                Write-Host "execute o PowerShell como Administrador." -ForegroundColor Yellow
                return
            }
            
            # Confirmar remoção
            Write-Host "`nVocê selecionou:" -ForegroundColor Yellow
            Write-Host "Nome: $($selectedApp.Nome)" -ForegroundColor Cyan
            Write-Host "Tipo: $($selectedApp.Tipo)" -ForegroundColor Cyan
            Write-Host "Caminho: $($selectedApp.Caminho)" -ForegroundColor Cyan
            
            $confirm = Read-Host "`nTem certeza que deseja remover este item? (S/N)"
            
            if ($confirm -match '^[SsYy]') {
                try {
                    if ($selectedApp.IsLink) {
                        # Remover atalho da pasta de inicialização
                        Remove-Item -Path $selectedApp.Local -Force -ErrorAction Stop
                        Write-Host "`nAtalho removido com sucesso!" -ForegroundColor Green
                    }
                    elseif ($selectedApp.Tipo -like "*Registro*") {
                        # Remover do registro
                        $regPath = if ($selectedApp.Tipo -eq "Registro Usuário") {
                            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                        } else {
                            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
                        }
                        
                        Remove-ItemProperty -Path $regPath -Name $selectedApp.Nome -ErrorAction Stop
                        Write-Host "`nEntrada do registro removida com sucesso!" -ForegroundColor Green
                    }
                    elseif ($selectedApp.Tipo -like "*Serviço*") {
                        Write-Host "`nServiços devem ser gerenciados através do 'services.msc'" -ForegroundColor Yellow
                        Write-Host "Ou usando: Set-Service -Name '$($selectedApp.Nome)' -StartupType Manual" -ForegroundColor Yellow
                    }
                }
                catch {
                    Write-Host "`nErro ao remover: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            else {
                Write-Host "`nOperação cancelada pelo usuário." -ForegroundColor Yellow
            }
        }
        
        "2" {
            # Remover todos os aplicativos
            Write-Host "`nAVISO: Esta ação irá remover TODOS os aplicativos de inicialização" -ForegroundColor Red
            Write-Host "(exceto serviços). Isso pode afetar o comportamento do sistema." -ForegroundColor Red
            
            $confirm = Read-Host "`nTem ABSOLUTA certeza? (digite 'SIM' para confirmar)"
            
            if ($confirm -eq "SIM") {
                $removedCount = 0
                
                foreach ($app in $startupApps | Where-Object {$_.Tipo -notlike "*Serviço*"}) {
                    try {
                        if ($app.IsLink) {
                            # Verificar se precisa de admin para pasta Todos Usuários
                            if ($app.Tipo -like "*Todos*" -and -not $isAdmin) {
                                Write-Host "Pulando '$($app.Nome)': requer admin" -ForegroundColor Yellow
                                continue
                            }
                            
                            if (Test-Path $app.Local) {
                                Remove-Item -Path $app.Local -Force -ErrorAction Stop
                                $removedCount++
                            }
                        }
                        elseif ($app.Tipo -like "*Registro*") {
                            # Verificar admin para registro HKLM
                            if ($app.Tipo -eq "Registro Máquina" -and -not $isAdmin) {
                                Write-Host "Pulando '$($app.Nome)': requer admin" -ForegroundColor Yellow
                                continue
                            }
                            
                            $regPath = if ($app.Tipo -eq "Registro Usuário") {
                                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                            } else {
                                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
                            }
                            
                            if (Test-Path $regPath) {
                                Remove-ItemProperty -Path $regPath -Name $app.Nome -ErrorAction Stop
                                $removedCount++
                            }
                        }
                    }
                    catch {
                        Write-Host "Erro ao remover '$($app.Nome)': $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                
                Write-Host "`nTotal de $removedCount itens removidos." -ForegroundColor Green
            }
            else {
                Write-Host "`nOperação cancelada." -ForegroundColor Yellow
            }
        }
        
        "3" {
            Write-Host "`nSaindo..." -ForegroundColor Yellow
        }
    }
    
    # Limpar objetos COM
    if ($shell) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    }
}# completa , funciona e bem detalhada 

function RepairInstalledApps {
    FunctionHeader -title "REPARANDO PROGRAMAS INSTALADOS"
    
    if (Checking_winget) {
        Write-Host "Reparando programas instalados via Winget..." -ForegroundColor Cyan
        Write-Host "Esta operação pode demorar alguns minutos." -ForegroundColor Yellow
        
        try {
            # Obtém lista de programas com problemas
            $brokenApps = winget list --verify --disable-interactivity | Out-String
            $appsToRepair = $brokenApps -split "`n" | Where-Object { $_ -match "Verification failed" }
            
            if ($appsToRepair.Count -eq 0) {
                Write-Host "Nenhum programa com problemas de verificação encontrado." -ForegroundColor Green
                Write-Output "Pressione Enter para continuar."; Read-Host
                return
            }
            
            Write-Host "Programas que serão reparados:" -ForegroundColor Yellow
            $appsToRepair | ForEach-Object {
                $appName = $_ -replace ".*Verification failed for ", ""
                Write-Host "  - $appName" -ForegroundColor Red
            }
            
            $confirm = Read-Host "`nDeseja prosseguir com o reparo? (S/N)"
            if ($confirm -match '^[SsYy]') {
                $successCount = 0
                $failCount = 0
                
                foreach ($app in $appsToRepair) {
                    $appId = $app -split " " | Select-Object -First 1
                    Write-Host "Reparando: $appId" -ForegroundColor White
                    
                    try {
                        winget repair --id $appId --accept-source-agreements --accept-package-agreements
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "  $appId reparado com sucesso" -ForegroundColor Green
                            $successCount++
                        } else {
                            Write-Host "  Falha ao reparar $appId" -ForegroundColor Red
                            $failCount++
                        }
                    } catch {
                        Write-Host "  Erro ao reparar $appId : $($_.Exception.Message)" -ForegroundColor Red
                        $failCount++
                    }
                    Start-Sleep -Seconds 1
                }
                
                Write-Host "`n=== RESUMO DO REPARO ===" -ForegroundColor Magenta
                Write-Host "Programas reparados: $successCount" -ForegroundColor Green
                Write-Host "Programas com falha: $failCount" -ForegroundColor Red
            } else {
                Write-Host "Operação cancelada pelo usuário." -ForegroundColor Yellow
            }
        } catch {
            Write-Warning "Erro ao verificar programas: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Winget não está disponível."
    }
    Write-Output "`nPressione Enter para continuar."; Read-Host
}

# Função para limpar cache de aplicativos
function ClearAppCache {
    FunctionHeader -title "LIMPEZA DE CACHE DE APLICATIVOS"
    
    Write-Host "Limpando cache de aplicativos..." -ForegroundColor Cyan
    # sid do usuário
    $UserSID = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    function Test-RecycleBin {
        param($Drive = $env:SystemDrive)
        $path = "$Drive`\$Recycle.Bin\$UserSID"
        return (Get-Item $path -Force -ErrorAction SilentlyContinue) -ne $null
    }
    # Locais comuns de cache
    $cacheLocations = @(
        "$env:LOCALAPPDATA\Temp",
        "$env:TEMP",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:SystemDrive`\$Recycle.Bin\$UserSID"
    )
    
    $totalFreed = 0
    $successCount = 0
    $failCount = 0
    
    foreach ($location in $cacheLocations) {
        if (Test-Path $location) {
            try {
                Write-Host "Limpando: $location" 
                $files = Get-ChildItem -Path $location -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
                
                if ($files) {
                    # CORREÇÃO: Adicionado '-Property Length' ao Measure-Object
                    $sizeBefore = ($files | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
                    $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    $totalFreed += $sizeBefore
                    $successCount++
                    $sizeBefore = [math]::Round($sizeBefore ,2)
                    Write-Host "Liberado: $sizeBefore MB" 
                } else {
                    Write-Host "Nenhum arquivo antigo encontrado" -ForegroundColor Gray
                }
            } catch {
                Write-Host "Erro ao limpar: $($_.Exception.Message)" -ForegroundColor Red
                $failCount++
            }
        } else {
            Write-Host "Local não encontrado: $location" -ForegroundColor DarkGray
        }
    }
    
    # Limpar cache do Windows Update
    Write-Host "`nLimpando cache do Windows Update..." -ForegroundColor Cyan
    try {
        Write-Host "Parando serviço Windows Update..." -ForegroundColor White
        Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
        
        $wuPath = "$env:WINDIR\SoftwareDistribution\Download"
        if (Test-Path $wuPath) {
            $wuSizeBefore = (Get-ChildItem -Path $wuPath -Recurse -Force -ErrorAction SilentlyContinue | 
                           Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
            $sizeMb = [math]::Round($wuSizeBefore ,2)
            Write-Host "  Tamanho do cache: $sizeMb MB" 
            
            Remove-Item "$wuPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            $totalFreed += $wuSizeBefore
            $successCount++
            Write-Host "Cache do Windows Update limpo" -ForegroundColor Green
        }
        
        Write-Host "Iniciando serviço Windows Update..." -ForegroundColor White
        Start-Service wuauserv -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Erro ao limpar cache do Windows Update: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    # Limpar thumbnail cache
    Write-Host "`nLimpando cache de thumbnails..." -ForegroundColor Cyan
    try {
        $thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
        if (Test-Path $thumbPath) {
            $thumbFiles = Get-ChildItem -Path $thumbPath -Filter "*.db" -Force -ErrorAction SilentlyContinue
            if ($thumbFiles) {
                $thumbSize = ($thumbFiles | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
                $thumbFiles | Remove-Item -Force -ErrorAction SilentlyContinue
                $totalFreed += $thumbSize
                $successCount++
                $sizeMbThumb = [math]::Round($thumbSize ,2)
                Write-Host "Cache de thumbnails limpo: $sizeMbThumb MB" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "Não foi possível limpar cache de thumbnails" -ForegroundColor Gray
    }
    
    # Limpar cache do DNS
    Write-Host "`nLimpando cache DNS..." -ForegroundColor Cyan
    try {
        ipconfig /flushdns | Out-Null
        Write-Host "Cache DNS limpo" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "Erro ao limpar cache DNS" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host "`n" + ("=" * 65) -ForegroundColor Cyan
    Write-Host "=== RESUMO DA LIMPEZA ===" -ForegroundColor Magenta
    $totalFreed = [math]::Round($totalFreed ,2)
    Write-Host "Espaço total liberado: $totalFreed MB "
    Write-Host "Operações bem-sucedidas: $successCount" -ForegroundColor Green
    Write-Host "Erros encontrados: $failCount" -ForegroundColor Red
    
    # Feedback baseado no total liberado
    if ($totalFreed -gt 100) {
        Write-Host "`nLimpeza significativa realizada! ($totalFreed MB)" -ForegroundColor Green
    } elseif ($totalFreed -gt 0) {
        Write-Host "`nLimpeza realizada ($totalFreed MB)" -ForegroundColor Green
    } else {
        Write-Host "`nNenhum arquivo de cache antigo encontrado" -ForegroundColor Yellow
    }
    
    # Opção para limpar prefetch
    $prefetch = Read-Host "`nDeseja limpar arquivos Prefetch? (S/N)"
    if ($prefetch -match '^[SsYy]') {
        try {
            $prefetchPath = "$env:WINDIR\Prefetch"
            if (Test-Path $prefetchPath) {
                $prefetchSize = (Get-ChildItem -Path $prefetchPath -Force -ErrorAction SilentlyContinue | 
                               Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
                Remove-Item "$prefetchPath\*" -Force -ErrorAction SilentlyContinue
                $totalFreed += $prefetchSize
                $prefetchSize = [math]::Round($prefetchSize ,2)
                Write-Host "Arquivos Prefetch limpos: $prefetchSize MB" -ForegroundColor Green
            }
        } catch {
            Write-Host "Erro ao limpar Prefetch" -ForegroundColor Red
        }
    }
    
    # Opção para limpar Recent
    $recent = Read-Host "`nDeseja limpar arquivos Recentes? (S/N)"
    if ($recent -match '^[SsYy]') {
        try {
            $recentPath = "$env:APPDATA\Microsoft\Windows\Recent"
            if (Test-Path $recentPath) {
                $recentSize = (Get-ChildItem -Path $recentPath -Force -ErrorAction SilentlyContinue | 
                             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
                Remove-Item "$recentPath\*" -Force -Recurse -ErrorAction SilentlyContinue
                $totalFreed += $recentSize
                $recentSize = [math]::Round($recentSize ,2)
                Write-Host "Arquivos Recentes limpos: $recentSize MB" -ForegroundColor Green
            }
        } catch {
            Write-Host "Erro ao limpar arquivos Recentes" -ForegroundColor Red
        }
    }
    
    Write-Host "`n" + ("=" * 65) -ForegroundColor Cyan
    $totalFreed = [math]::Round($totalFreed ,2)
    Write-Host "Espaço total liberado final: $totalFreed MB"
    
    Write-Output "`nPressione Enter para continuar."; Read-Host
}
# # Função para verificar programas com inicialização automática
# function CheckStartupApps {
#     FunctionHeader -title "VERIFICANDO PROGRAMAS COM INICIALIZAÇÃO AUTOMÁTICA"
    
#     Write-Host "Coletando informações de programas que iniciam automaticamente..." -ForegroundColor Cyan
    
#     # 1. Verificar pasta de inicialização do usuário
#     $userStartupPath = [Environment]::GetFolderPath('Startup')
#     Write-Host "`n[Pasta de Inicialização do Usuário]" -ForegroundColor Yellow
#     Write-Host "Caminho: $userStartupPath" -ForegroundColor Gray
    
#     if (Test-Path $userStartupPath) {
#         $userApps = Get-ChildItem -Path $userStartupPath -Filter *.lnk -ErrorAction SilentlyContinue
#         if ($userApps) {
#             $userApps | ForEach-Object {
#                 $shell = New-Object -ComObject WScript.Shell
#                 $link = $shell.CreateShortcut($_.FullName)
#                 Write-Host "  • $($_.Name): $($link.TargetPath)" -ForegroundColor White
#             }
#         } else {
#             Write-Host "  Nenhum atalho encontrado" -ForegroundColor Gray
#         }
#     }
    
#     # 2. Verificar registro HKCU
#     Write-Host "`n[Registro - Usuário Atual (HKCU)]" -ForegroundColor Yellow
#     $regPathUser = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
#     if (Test-Path $regPathUser) {
#         $regUser = Get-ItemProperty -Path $regPathUser
#         $regUser.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object {
#             Write-Host "  • $($_.Name): $($_.Value)" -ForegroundColor White
#         }
#     }
    
#     # 3. Verificar registro HKLM
#     Write-Host "`n[Registro - Máquina (HKLM)]" -ForegroundColor Yellow
#     $regPathMachine = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
#     if (Test-Path $regPathMachine) {
#         $regMachine = Get-ItemProperty -Path $regPathMachine
#         $regMachine.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object {
#             Write-Host "  • $($_.Name): $($_.Value)" -ForegroundColor White
#         }
#     }
    
#     # 4. Verificar serviços que iniciam automaticamente
#     Write-Host "`n[Serviços de Inicialização Automática]" -ForegroundColor Yellow
#     $autoServices = Get-Service | Where-Object {$_.StartType -eq 'Automatic'} | Select-Object -First 15
#     $autoServices | ForEach-Object {
#         Write-Host "  • $($_.Name): $($_.DisplayName)" -ForegroundColor White
#     }
    
#     if ($autoServices.Count -eq 15) {
#         Write-Host "  (Mostrando apenas 15 serviços. Use 'services.msc' para ver todos)" -ForegroundColor Gray
#     }
    
#     # 5. Verificar com WMIC
#     Write-Host "`n[Tarefas Agendadas de Inicialização]" -ForegroundColor Yellow
#     try {
#         $startupTasks = Get-CimInstance Win32_StartupCommand | Select-Object -First 10
#         $startupTasks | ForEach-Object {
#             Write-Host "  • $($_.Name): $($_.Command)" -ForegroundColor White
#         }
#     } catch {
#         Write-Host "  Erro ao acessar tarefas agendadas" -ForegroundColor Red
#     }
    
#     Write-Host "`n" + ("=" * 65) -ForegroundColor Cyan
#     Write-Host "Dica: Use o Gerenciador de Tarefas para mais detalhes (Ctrl+Shift+Esc)" -ForegroundColor Yellow
    
#     Write-Output "`nPressione Enter para continuar."; Read-Host
    
#     # Limpar objetos COM
#     if ($shell) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null }
# }

# # Função para otimizar inicialização de programas
# function OptimizeStartupApps {
#     FunctionHeader -title "OTIMIZANDO INICIALIZAÇÃO DE PROGRAMAS"
    
#     Write-Host "Analisando impacto na inicialização..." -ForegroundColor Cyan
    
#     # Verificar programas com alto impacto (via PowerShell 5.1+ ou alternativa)
#     try {
#         # Tentar usar o Get-CimInstance para obter informações de inicialização
#         $startupItems = Get-CimInstance Win32_StartupCommand | ForEach-Object {
#             [PSCustomObject]@{
#                 Nome = $_.Name
#                 Comando = $_.Command
#                 Local = $_.Location
#             }
#         }
        
#         if ($startupItems) {
#             Write-Host "Programas encontrados:" -ForegroundColor Yellow
#             $startupItems | ForEach-Object {
#                 Write-Host "  • $($_.Nome)" -ForegroundColor White
#             }
            
#             Write-Host "`nRecomendações:" -ForegroundColor Cyan
#             Write-Host "1. Programas pesados como Steam, Discord, Skype podem atrasar a inicialização" -ForegroundColor Yellow
#             Write-Host "2. Utilitários de atualização (Adobe, Google, etc.) podem ser desativados" -ForegroundColor Yellow
#             Write-Host "3. Programas de nuvem (OneDrive, Dropbox) podem iniciar após login" -ForegroundColor Yellow
            
#             $action = Read-Host "`nDeseja desativar algum programa da inicialização? (S/N)"
            
#             if ($action -match '^[SsYy]') {
#                 Write-Host "`nOpções de desativação:" -ForegroundColor Yellow
#                 Write-Host "1. Desativar via Gerenciador de Tarefas (recomendado para iniciantes)"
#                 Write-Host "2. Desativar via registro (avançado)"
#                 Write-Host "3. Cancelar"
                
#                 $option = Read-Host "`nEscolha uma opção (1-3)"
                
#                 switch ($option) {
#                     "1" {
#                         Write-Host "`nAbrindo Gerenciador de Tarefas..." -ForegroundColor Cyan
#                         Write-Host "Vá para a aba 'Inicializar' para gerenciar programas." -ForegroundColor Yellow
#                         Write-Host "Clique com o botão direito no programa e selecione 'Desabilitar'." -ForegroundColor Yellow
#                         Start-Process "taskmgr.exe" -ArgumentList "/0 /startup"
#                     }
#                     "2" {
#                         # Desativar via registro (apenas HKCU)
#                         Write-Host "`nDesativando programas do registro do usuário..." -ForegroundColor Cyan
#                         $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                        
#                         if (Test-Path $regPath) {
#                             $regItems = Get-ItemProperty -Path $regPath
#                             $items = $regItems.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"}
                            
#                             if ($items) {
#                                 Write-Host "Programas no registro:" -ForegroundColor Yellow
#                                 $i = 1
#                                 $items | ForEach-Object {
#                                     Write-Host "  [$i] $($_.Name)" -ForegroundColor White
#                                     $i++
#                                 }
                                
#                                 $choice = Read-Host "`nDigite o número do programa para remover (ou 0 para cancelar)"
#                                 if ($choice -ne "0" -and $choice -le $items.Count) {
#                                     $selected = $items[$choice - 1]
#                                     $confirm = Read-Host "Remover '$($selected.Name)'? (S/N)"
                                    
#                                     if ($confirm -match '^[SsYy]') {
#                                         Remove-ItemProperty -Path $regPath -Name $selected.Name -Force
#                                         Write-Host "✓ Programa removido da inicialização" -ForegroundColor Green
#                                     }
#                                 }
#                             }
#                         }
#                     }
#                 }
#             }
#         } else {
#             Write-Host "Não foram encontrados programas para otimizar." -ForegroundColor Green
#         }
#     } catch {
#         Write-Host "Não foi possível obter informações detalhadas de inicialização." -ForegroundColor Yellow
#         Write-Host "Abra o Gerenciador de Tarefas (Ctrl+Shift+Esc) para ver os programas de inicialização." -ForegroundColor Yellow
#     }
    
#     # Dicas gerais de otimização
#     Write-Host "`n=== DICAS DE OTIMIZAÇÃO ===" -ForegroundColor Magenta
#     Write-Host "• Desative serviços desnecessários (veja opção 'Serviços do Sistema')" -ForegroundColor White
#     Write-Host "• Use SSD para melhor performance de inicialização" -ForegroundColor White
#     Write-Host "• Mantenha drivers atualizados" -ForegroundColor White
#     Write-Host "• Desfragmente o disco (apenas para HDD)" -ForegroundColor White
    
#     Write-Output "`nPressione Enter para continuar."; Read-Host
# }






# ======================================== GLOBAIS ==========================================================================
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



# ============ CHAMANDO DAS FUNCOES ============

ClearAppCache