
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


function Gerenciar-AppsInicializacao {   
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
    
     $itemsInTable = $startupItems| ForEach-Object -Begin { $i = 1 } -Process {
        $_ | Add-Member -NotePropertyName 'Num' -NotePropertyValue $i -PassThru
        $i++
    }
    # Exibe os itens na tela
    # Write-Host "Aplicativos na inicializacao do sistema:"
    # for ($i = 0; $i -lt $startupItems.Count; $i++) {
    #     Write-Host "[$($i + 1)] - $($startupItems[$i].Nome)"
    # }
    $itemsInTable | Select-Object Num, Name | Format-Table -AutoSize | Out-Host
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






function Manage-StartupApps {
   
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
}

# Para usar a função:
Manage-StartupApps