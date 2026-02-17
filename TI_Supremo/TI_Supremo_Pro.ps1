# Define o título da janela do PowerShell
$Host.UI.RawUI.WindowTitle = "TI Supremo - Ferramenta do TI Profissional"
# Configurar cores do console
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"
# define o tamanho da janela do PowerShell
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(85, 45)

# Verifica se a sessão é Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process powershell -Verb RunAs -ArgumentList $argList
    exit
}

# =============================== FUNÇÃO PRINCIPAL ================================
function MainMenu {
    $running = $true
    do {
        FunctionHeader -title "MENU PRINCIPAL TI SUPREMO PRO"
        Write-Output "                  [ 1 ] ==== APLICATIVOS"
        Write-Output "                  [ 2 ] ==== SISTEMA"
        Write-Output "                  [ 3 ] ==== REDE"
        Write-Output "                  [ 4 ] ==== UTILITARIOS"
        Write-Output "                  [ 0 ] ==== SAIR"
        Write-Output ""
        $choice = Read-Host "  Escolha uma opcao "

        switch ($choice) {
            "1" { Aplications }
            "2" { System }
            "3" { Network }
            "4" { Utilities }
            "0" { $running = $false }
            default { Write-Host "Opcao invalida. Pressione Enter para tentar novamente." -ForegroundColor Red; Read-Host }
        }
    } while ($running)
}

# ============================= FUNÇÕES DE APLICATIVOS ===============================
function Aplications {
    $running = $true
    do {
        FunctionHeader -title "MENU FERRAMENTAS DE APLICATIVOS"
        Write-Output "          [ 1 ]  = INSTALAR PROGRAMAS DO ARQUIVO TXT" 
        Write-Output "          [ 2 ]  = VERIFICAR PROGRAMAS INSTALADOS"
        Write-Output "          [ 3 ]  = ATUALIZAR PROGRAMAS INSTALADOS"
        Write-Output "          [ 4 ]  = DESINSTALAR PROGRAMAS ESPECIFICOS"
        Write-Output "          [ 5 ]  = REPARAR PROGRAMAS INSTALADOS " 
        Write-Output "          [ 6 ]  = LIMPAR CACHE DE APLICATIVOS"
        Write-Output "          [ 7 ]  = VERIFICAR PROGRAMAS COM INICIAL AUTOMATICA"
        Write-Output "          [ 8 ]  = OTIMIZAR INICIALIZACAO DE PROGRAMAS"
        Write-Output "          [ 9 ]  = VERIFICAR APLICATIVOS VULNERAVEIS"
        Write-Output "          [ 0 ]  = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        $choice = Read-Host "  Escolha uma opcao "

        switch ($choice) {
            "1"  { InstallAppsTxt }
            "2"  { CheckInstalledApps }
            "3"  { UpdateUnistallApps -Action 'Update' }
            "4"  { UpdateUnistallApps -Action 'Uninstall' }
            "5"  { RepairInstalledApps }
            "6"  { ClearAppCache }
            "7"  { CheckStartupApps }
            "8"  { OptimizeStartupApps }
            "9"  { CheckVulnerableApps }
            "0"  { $running = $false }
            default { Write-Host "Opcao invalida." -ForegroundColor Red; Read-Host }
        }
    } while ($running)
}

function InstallAppsTxt {
    [CmdletBinding()]
    param([switch]$Force = $false)
    FunctionHeader -title "INSTALANDO APLICATIVOS DO ARQUIVO TXT"
    $scriptDirectory = Get-ScriptDirectory  
    $attempt_count = 0
    
    do {
        $FileName = Read-Host "Digite o nome do arquivo txt (ex: apps.txt)"
        $FilePath = Join-Path -Path $scriptDirectory -ChildPath $FileName
        if (-not (Test-Path $FilePath)) {
            Write-Warning "Arquivo não encontrado: $FilePath"; Read-Host
            $attempt_count++
        } elseif ((Get-Item $FilePath).Extension -ne ".txt") {
            Write-Warning "O arquivo deve ser .txt"; Read-Host
            $attempt_count++            
        }
        if($attempt_count -ge 3) { return }
    } while(-not (Test-Path $FilePath) -or (Get-Item $FilePath).Extension -ne ".txt")

    $apps = Get-Content $FilePath | Where-Object { $_.Trim() -ne "" -and $_.Trim() -notlike "#*" }
    if ($apps.Count -eq 0) { Write-Warning "Arquivo vazio."; return }
    
    Write-Host "Encontrados $($apps.Count) aplicativos para instalação." -ForegroundColor Magenta
    if (-not $Force) {
        $confirmation = Read-Host "Deseja prosseguir? (S/N)"
        if ($confirmation -notmatch '^[SsYy]') { return }
    }
    
    if (Checking_winget) {
        $i = 0
        foreach ($app in $apps) {
            $i++
            Write-Progress -Activity "Instalando Aplicativos" -Status "Processando: $app" -PercentComplete (($i / $apps.Count) * 100)
            Write-Host "[$i/$($apps.Count)] Instalando: $app..." -ForegroundColor Cyan
            try {
                winget install --id $app --silent --accept-package-agreements --accept-source-agreements --force
                if ($LASTEXITCODE -eq 0) { Write-Host "  [OK] $app instalado." -ForegroundColor Green }
                else { Write-Host "  [ERRO] Falha no código $LASTEXITCODE" -ForegroundColor Red }
            } catch { Write-Host "  [FALHA CRITICA] $_" -ForegroundColor Red }
        }
    }
    Read-Host "Concluido. Pressione Enter."
}

function CheckInstalledApps {
    FunctionHeader -title "VERIFICANDO PROGRAMAS INSTALADOS"
    if (Checking_winget) {
        Write-Host "Coletando dados do sistema... Aguarde." -ForegroundColor Cyan
        $apps = VerifyApps
        if ($apps) {
            $apps | Out-GridView -Title "TI Supremo - Programas Instalados"
            Write-Host "Lista aberta em janela separada para melhor visualização." -ForegroundColor Green
        }
    }
    Read-Host "Pressione Enter."
}

function UpdateUnistallApps {
    param([Parameter(Mandatory)][ValidateSet('Update','Uninstall')][string]$Action)
    $title = if ($Action -eq 'Update') { "ATUALIZANDO PROGRAMAS" } else { "DESINSTALANDO PROGRAMAS" }
    FunctionHeader -title $title

    if (-not (Checking_winget)) { return }
    
    Write-Host "Sincronizando repositórios e verificando lista..." -ForegroundColor Cyan
    if ($Action -eq 'Update') {
        $upRaw = winget upgrade --accept-source-agreements | Out-String
        $apps = $upRaw -split "`n" | Where-Object { $_ -match '^\s*\d+' -or $_ -match '\.\w'} | ForEach-Object {
            $c = $_ -split '\s{2,}'
            if ($c.Count -ge 4) { [pscustomobject]@{ Name=$c[0].Trim(); ID=$c[1].Trim(); Version=$c[2].Trim(); Available=$c[3].Trim() } }
        }
    } else {
        $apps = VerifyApps
    }

    if (-not $apps) { Write-Host "Nenhum item encontrado para esta ação." -ForegroundColor Yellow; Read-Host; return }

    $appsWithIdx = $apps | ForEach-Object -Begin { $i = 1 } -Process { $_ | Add-Member -NotePropertyName 'Num' -NotePropertyValue $i -PassThru; $i++ }
    $appsWithIdx | Format-Table -AutoSize | Out-Host

    $sel = Read-Host "Selecione os números (ex: 1,3,5 ou 1-5) ou 'A' para todos"
    if ($sel -eq 'A') { $selectedIdx = 1..$apps.Count }
    else {
        $selectedIdx = foreach ($part in $sel -split ',') {
            if ($part -match '^\d+$') { [int]$part }
            elseif ($part -match '^(\d+)-(\d+)$') { $s,$e = $part -split '-'; [int]$s..[int]$e }
        }
    }
    $selectedIdx = $selectedIdx | Where-Object { $_ -ge 1 -and $_ -le $apps.Count } | Sort-Object -Unique

    if ($selectedIdx) {
        foreach ($idx in $selectedIdx) {
            $app = $appsWithIdx[$idx-1]
            Write-Host "Processando: $($app.Name)..." -ForegroundColor Cyan
            if ($Action -eq 'Update') { winget upgrade --id $app.ID --silent --accept-package-agreements }
            else { winget uninstall --id $app.ID --silent --force }
        }
    }
    Read-Host "Operação finalizada. Enter."
}

function RepairInstalledApps {
    FunctionHeader -title "REPARO AVANÇADO DE APLICATIVOS"
    if (Checking_winget) {
        $apps = VerifyApps
        $selected = $apps | Out-GridView -Title "Selecione o programa para REPARAR" -OutputMode Single
        if ($selected) {
            Write-Host "Iniciando reparo de $($selected.Name)..." -ForegroundColor Cyan
            winget repair --id $selected.ID --accept-source-agreements
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Reparo via Winget não disponível. Abrindo painel de controle..."
                Start-Process "appwiz.cpl"
            }
        }
    }
    Read-Host "Enter para voltar."
}

function ClearAppCache {
    FunctionHeader -title "LIMPEZA PROFUNDA DE CACHE"
    $tasks = @(
        @{ Name="Windows Store"; Cmd={ wsreset.exe }; Desc="Resetando cache da loja..." },
        @{ Name="Winget Source"; Cmd={ winget source reset --force }; Desc="Limpando fontes do winget..." },
        @{ Name="Spotify Cache"; Cmd={ Remove-Item "$env:LOCALAPPDATA\Spotify\Storage\*" -Recurse -Force -ErrorAction SilentlyContinue }; Desc="Limpando cache do Spotify..." },
        @{ Name="Discord Cache"; Cmd={ Remove-Item "$env:APPDATA\discord\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue }; Desc="Limpando cache do Discord..." }
    )
    
    foreach ($task in $tasks) {
        Write-Host $task.Desc -ForegroundColor Cyan
        & $task.Cmd
        Write-Host "  [OK] $($task.Name)" -ForegroundColor Green
    }
    Read-Host "Limpeza concluída. Enter."
}

function CheckStartupApps {
    FunctionHeader -title "ANALISE DE INICIALIZACAO"
    $startup = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User
    $startup | Format-Table -AutoSize | Out-Host
    
    $impact = Get-ItemProperty "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemSettings\Apps\*" -ErrorAction SilentlyContinue
    Write-Host "`nDica: Use o Gerenciador de Tarefas (Ctrl+Shift+Esc) para ver o impacto medido pelo Windows." -ForegroundColor Yellow
    Read-Host "Enter."
}

function OptimizeStartupApps {
    FunctionHeader -title "OTIMIZACAO DE ARRANQUE"
    Write-Host "1. Desativando serviços de telemetria desnecessários..." -ForegroundColor Cyan
    $services = @("DiagTrack", "dmwappushservice")
    foreach ($s in $services) {
        Stop-Service -Name $s -ErrorAction SilentlyContinue
        Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  [OK] Servico $s desativado." -ForegroundColor Green
    }
    Write-Host "2. Abrindo aba de inicialização para ajuste manual..." -ForegroundColor Cyan
    Start-Process taskmgr.exe
    Read-Host "Otimização básica concluída. Enter."
}

function CheckVulnerableApps {
    FunctionHeader -title "SCANNER DE VULNERABILIDADES (CVE)"
    Write-Host "Cruzando versões instaladas com banco de dados de atualizações..." -ForegroundColor Cyan
    if (Checking_winget) {
        $vulnerable = winget upgrade | Select-String "vulnerab|security|update"
        if ($vulnerable) { Write-Host "Atenção: Existem atualizações de segurança pendentes!" -ForegroundColor Red }
        winget upgrade
    }
    Read-Host "Scan concluído. Enter."
}

# ============================= FUNÇÕES DE SISTEMA ===================================
function System {
    $running = $true
    do {
        FunctionHeader -title "MENU FERRAMENTAS DO SISTEMA"
        Write-Output "          [ 1 ] = VERIFICAR USO DE DISCO (DETALHADO)"
        Write-Output "          [ 2 ] = VERIFICAR USO DE MEMORIA (REAL-TIME)"
        Write-Output "          [ 3 ] = VERIFICAR USO DE CPU (TOP PROCESSOS)"
        Write-Output "          [ 4 ] = LIMPAR ARQUIVOS TEMP (CALCULAR ESPACO)"
        Write-Output "          [ 5 ] = ANALISAR SERVICOS CRITICOS"
        Write-Output "          [ 6 ] = LIMPEZA DE DISCO AVANCADA"
        Write-Output "          [ 7 ] = REPARO DISM (ONLINE RESTORE)"
        Write-Output "          [ 8 ] = VERIFICAR INTEGRIDADE SFC"
        Write-Output "          [ 9 ] = COMBO REPARO TOTAL (DISM + SFC)"
        Write-Output "          [ 10 ] = ATIVAR WINDOWS/OFFICE (MASSGRAVE)"
        Write-Output "          [ 0 ] = VOLTAR AO MENU PRINCIPAL " 
        Write-Output ""
        $choice = Read-Host "  Escolha uma opcao "

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
            "10" { activate_windows_office }
            "0" { $running = $false }
            default { Write-Host "Opcao invalida." -ForegroundColor Red; Read-Host }
        }
    } while ($running)
}

function check_disk_usage {
    FunctionHeader -title "ANALISE DE ARMAZENAMENTO"
    Get-Volume | Where-Object {$_.DriveLetter} | Select-Object DriveLetter, FileSystemLabel, 
        @{Name="Tamanho(GB)";Expression={[math]::Round($_.Size/1GB,2)}},
        @{Name="Livre(GB)";Expression={[math]::Round($_.SizeRemaining/1GB,2)}},
        @{Name="Uso(%)";Expression={[math]::Round((1-($_.SizeRemaining/$_.Size))*100,1)}} | 
        Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}

function check_memory_usage {
    FunctionHeader -title "MONITOR DE MEMORIA RAM"
    $os = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $used = $total - $free
    $percent = [math]::Round(($used/$total)*100, 1)
    
    Write-Host "Status da RAM:" -ForegroundColor Cyan
    Write-Host "  Total: $total GB"
    Write-Host "  Usado: $used GB ($percent%)" -ForegroundColor (if($percent -gt 80){"Red"}else{"Yellow"})
    Write-Host "  Livre: $free GB" -ForegroundColor Green
    
    Write-Host "`nTop 5 Processos por Consumo:" -ForegroundColor Cyan
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{Name="RAM(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}} | Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}

function check_cpu_usage {
    FunctionHeader -title "MONITOR DE PROCESSAMENTO"
    Write-Host "Capturando carga atual..." -ForegroundColor Cyan
    $cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average
    Write-Host "Carga Global: $($cpu.Average)%" -ForegroundColor (if($cpu.Average -gt 70){"Red"}else{"Green"})
    
    Write-Host "`nProcessos mais ativos:" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 8 Name, CPU, Id | Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}

function clear_temp_files {
    FunctionHeader -title "LIMPEZA INTELIGENTE DE TEMPORARIOS"
    $paths = @("$env:TEMP", "$env:windir\Temp", "$env:LOCALAPPDATA\Temp")
    $totalFreed = 0
    
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $files = Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue
            $size = ($files | Measure-Object -Property Length -Sum).Sum
            $totalFreed += $size
            Write-Host "Limpando $p ($([math]::Round($size/1MB,2)) MB)..." -ForegroundColor Cyan
            Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "`nEspaço total liberado: $([math]::Round($totalFreed/1MB,2)) MB" -ForegroundColor Green
    Read-Host "Enter."
}

function check_system_services {
    FunctionHeader -title "SERVICOS CRITICOS DO WINDOWS"
    $critical = @("Winmgmt", "Spooler", "EventLog", "AppReadiness", "wuauserv")
    Get-Service -Name $critical | Select-Object Name, Status, StartType | Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}


function disk_cleanup {
    FunctionHeader -title "LIMPEZA DE DISCO AVANCADA"
    Write-Host "Iniciando Limpeza de Componentes do Windows (WinSxS)..." -ForegroundColor Cyan
    Dism /Online /Cleanup-Image /StartComponentCleanup
    Write-Host "Iniciando Limpeza de Disco Nativa..." -ForegroundColor Cyan
    cleanmgr /sagerun:1
    Read-Host "Enter."
}

function fix_system_issues {
    FunctionHeader -title "REPARO DE IMAGEM (DISM)"
    Write-Host "Verificando integridade da imagem..." -ForegroundColor Cyan
    Dism /Online /Cleanup-Image /CheckHealth
    Write-Host "Iniciando reparo profundo (RestoreHealth)..." -ForegroundColor Cyan
    Dism /Online /Cleanup-Image /RestoreHealth
    Read-Host "Enter."
}

function check_system_integrity {
    FunctionHeader -title "VERIFICACAO SFC"
    sfc /scannow
    Read-Host "Enter."
}

function restore_system_integrity {
    FunctionHeader -title "REPARO TOTAL DO SISTEMA"
    Write-Host "Etapa 1: DISM RestoreHealth" -ForegroundColor Cyan
    Dism /Online /Cleanup-Image /RestoreHealth
    Write-Host "Etapa 2: SFC Scannow" -ForegroundColor Cyan
    sfc /scannow
    Write-Host "Etapa 3: Resetando Winsock" -ForegroundColor Cyan
    netsh winsock reset
    Write-Host "Sistema restaurado." -ForegroundColor Green
    Read-Host "Enter."
}

function activate_windows_office {
    FunctionHeader -title "ATIVACAO (MASSGRAVE)"
    Write-Host "Conectando ao repositório Massgrave..." -ForegroundColor Cyan
    irm https://massgrave.dev/get | iex
    Read-Host "Enter."
}

# ============================= FUNÇÕES DE REDE ======================================
function Network {
    $running = $true
    do {
        FunctionHeader -title "MENU FERRAMENTAS DE REDE"
        Write-Output "          [ 1 ]  = TESTE DE LATENCIA (PING)"
        Write-Output "          [ 2 ]  = MEU IP (LOCAL E PUBLICO)"
        Write-Output "          [ 3 ]  = MAPA DE INTERFACES"
        Write-Output "          [ 4 ]  = MONITOR DE CONEXOES ATIVAS"
        Write-Output "          [ 5 ]  = RESETAR PILHA TCP/IP"
        Write-Output "          [ 6 ]  = DNS GOOGLE (8.8.8.8)"
        Write-Output "          [ 7 ]  = DNS CLOUDFLARE (1.1.1.1)"
        Write-Output "          [ 8 ]  = DNS OPENDNS"
        Write-Output "          [ 9 ]  = DNS PERSONALIZADO"
        Write-Output "          [ 10 ] = RESTAURAR DNS (DHCP)"
        Write-Output "          [ 11 ] = REINICIAR PLACAS DE REDE"
        Write-Output "          [ 0 ]  = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        $choice = Read-Host "  Escolha uma opcao "

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
            default { Write-Host "Opcao invalida." -ForegroundColor Red; Read-Host }
        }
    } while ($running)
}

function check_internet_connection {
    FunctionHeader -title "TESTE DE CONECTIVIDADE"
    $targets = @("8.8.8.8", "1.1.1.1", "www.google.com")
    foreach ($t in $targets) {
        Write-Host "Pingando $t..." -NoNewline
        if (Test-Connection -ComputerName $t -Count 2 -Quiet) {
            Write-Host " [OK]" -ForegroundColor Green
        } else {
            Write-Host " [FALHA]" -ForegroundColor Red
        }
    }
    Read-Host "Enter."
}

function check_ip_address {
    FunctionHeader -title "INFORMACOES DE IP"
    Write-Host "IP Local:" -ForegroundColor Cyan
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize | Out-Host
    
    Write-Host "IP Público:" -ForegroundColor Cyan
    try {
        $publicIP = (Invoke-WebRequest -Uri "https://api.ipify.org" -TimeoutSec 5).Content
        Write-Host "  $publicIP" -ForegroundColor Yellow
    } catch { Write-Warning "Não foi possível obter IP público." }
    Read-Host "Enter."
}

function check_network_config {
    FunctionHeader -title "MAPA DE REDE"
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed | Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}

function check_bandwidth_usage {
    FunctionHeader -title "CONEXOES ATIVAS (NETSTAT)"
    Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Sort-Object RemoteAddress | Select-Object -First 15 | Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}

function check_network_services {
    FunctionHeader -title "RESET DE REDE"
    Write-Host "Resetando Winsock e IP Stack..." -ForegroundColor Cyan
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    ipconfig /flushdns | Out-Null
    Write-Host "Rede resetada com sucesso." -ForegroundColor Green
    Read-Host "Enter."
}

function set_dns_internal {
    param($dns1, $dns2, $label)
    $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.Physical}
    foreach ($a in $adapters) {
        Write-Host "Aplicando $label em $($a.Name)..." -ForegroundColor Cyan
        Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ServerAddresses ($dns1, $dns2)
    }
    ipconfig /flushdns | Out-Null
}

function set_google_dns { FunctionHeader -title "DNS GOOGLE"; set_dns_internal "8.8.8.8" "8.8.4.4" "Google"; Read-Host "Enter" }
function set_cloudflare_dns { FunctionHeader -title "DNS CLOUDFLARE"; set_dns_internal "1.1.1.1" "1.0.0.1" "Cloudflare"; Read-Host "Enter" }
function set_opendns { FunctionHeader -title "DNS OPENDNS"; set_dns_internal "208.67.222.222" "208.67.220.220" "OpenDNS"; Read-Host "Enter" }

function add_custom_dns {
    FunctionHeader -title "DNS PERSONALIZADO"
    $p = Read-Host "DNS Primario"
    $s = Read-Host "DNS Secundario"
    if ($p -match '^\d{1,3}(\.\d{1,3}){3}$') { set_dns_internal $p $s "Personalizado" }
    else { Write-Host "IP Invalido." -ForegroundColor Red }
    Read-Host "Enter"
}

function restore_default_dns {
    FunctionHeader -title "RESTAURAR DNS (DHCP)"
    $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
    foreach ($a in $adapters) { Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ResetServerAddresses }
    Write-Host "DNS restaurado." -ForegroundColor Green
    Read-Host "Enter"
}

function restart_network_adapters {
    FunctionHeader -title "REINICIAR HARDWARE DE REDE"
    Get-NetAdapter | ForEach-Object {
        Write-Host "Reiniciando $($_.Name)..." -ForegroundColor Cyan
        Disable-NetAdapter -Name $_.Name -Confirm:$false
        Enable-NetAdapter -Name $_.Name -Confirm:$false
    }
    Read-Host "Enter."
}

# ============================= FUNÇÕES DE UTILITARIOS ===============================
function Utilities {
    $running = $true
    do {
        FunctionHeader -title "MENU FERRAMENTAS DE UTILITARIOS"
        Write-Output "          [ 1 ] = GERAR RELATORIO HTML COMPLETO"
        Write-Output "          [ 2 ] = CRIAR PONTO DE RESTAURACAO"
        Write-Output "          [ 3 ] = CRIAR NOVO USUARIO ADMIN"
        Write-Output "          [ 4 ] = ATIVAR CONTA ADMIN OCULTA"
        Write-Output "          [ 5 ] = DESATIVAR CONTA ADMIN OCULTA"
        Write-Output "          [ 6 ] = AGENDAR MODO SEGURANCA (BOOT)"
        Write-Output "          [ 7 ] = CANCELAR MODO SEGURANCA"
        Write-Output "          [ 8 ] = GERENCIAR HIBERNACAO (ON/OFF)"
        Write-Output "          [ 9 ] = DETALHES TECNICOS DO HARDWARE"
        Write-Output "          [ 0 ] = VOLTAR AO MENU PRINCIPAL "   
        Write-Output ""
        $choice = Read-Host "  Escolha uma opcao "

        switch ($choice) {
            "1" { generate_system_report }
            "2" { create_restore_point }
            "3" { create_admin_user }
            "4" { enable_builtin_admin }
            "5" { disable_builtin_admin }
            "6" { enable_safe_mode }
            "7" { disable_safe_mode }
            "8" { 
                $opt = Read-Host "1-Ativar, 2-Desativar"
                if($opt -eq '1'){enable_hibernation}else{disable_hibernation}
            }
            "9" { hardware_details }
            "0"  { $running = $false }
            default { Write-Host "Opcao invalida." -ForegroundColor Red; Read-Host }
        }
    } while ($running)
}

function generate_system_report {
    FunctionHeader -title "RELATORIO DO SISTEMA (HTML)"
    $path = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "Relatorio_TI_Supremo.html"
    Write-Host "Coletando dados detalhados..." -ForegroundColor Cyan
    Get-ComputerInfo | ConvertTo-Html -Title "Relatorio TI Supremo" -Body "<h1>Informacoes do Sistema</h1>" | Out-File $path
    Write-Host "Relatorio salvo no Desktop: $path" -ForegroundColor Green
    Start-Process $path
    Read-Host "Enter."
}

function create_restore_point {
    FunctionHeader -title "PONTO DE RESTAURACAO"
    Write-Host "Verificando se a proteção do sistema está ativa..." -ForegroundColor Cyan
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "TI_Supremo_Pro_Point" -RestorePointType "MODIFY_SETTINGS"
    Write-Host "Ponto de restauração criado." -ForegroundColor Green
    Read-Host "Enter."
}

function create_admin_user {
    FunctionHeader -title "CRIAR ADMINISTRADOR"
    $user = Read-Host "Nome do novo usuario"
    $pass = Read-Host -AsSecureString "Senha"
    try {
        $new = New-LocalUser -Name $user -Password $pass -FullName "$user Admin"
        Add-LocalGroupMember -Group "Administradores" -Member $user
        Write-Host "Usuario $user criado com sucesso." -ForegroundColor Green
    } catch { Write-Error "Falha ao criar usuario." }
    Read-Host "Enter."
}

function enable_builtin_admin { net user administrator /active:yes; Write-Host "Ativado."; Read-Host }
function disable_builtin_admin { net user administrator /active:no; Write-Host "Desativado."; Read-Host }

function enable_safe_mode {
    bcdedit /set {current} safeboot minimal
    Write-Host "O Windows entrará em Modo de Segurança no próximo reinício." -ForegroundColor Yellow
    Read-Host "Enter."
}

function disable_safe_mode {
    bcdedit /deletevalue {current} safeboot
    Write-Host "Boot normal restaurado." -ForegroundColor Green
    Read-Host "Enter."
}

function enable_hibernation { powercfg /hibernate on; Write-Host "Hibernacao Ativada."; Read-Host }
function disable_hibernation { powercfg /hibernate off; Write-Host "Hibernacao Desativada."; Read-Host }

function hardware_details {
    FunctionHeader -title "ESPECIFICACOES TECNICAS"
    $cpu = Get-CimInstance Win32_Processor
    $gpu = Get-CimInstance Win32_VideoController
    $disk = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size
    
    Write-Host "CPU: $($cpu.Name)" -ForegroundColor Cyan
    Write-Host "GPU: $($gpu.Name)" -ForegroundColor Cyan
    Write-Host "Discos:" -ForegroundColor Cyan
    $disk | Format-Table -AutoSize | Out-Host
    Read-Host "Enter."
}

# =============================== FUNÇÕES GLOBAIS ===================================
function FunctionHeader {
    param ([string]$title)
    Clear-Host
    Write-Output ("="*85)
    Write-Output "               $title"
    Write-Output ("="*85)
    Write-Output ""
}

function Checking_winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return $true }
    Write-Warning "Winget não encontrado. Instalando..."
    try {
        Install-Module -Name Microsoft.WinGet.Client -Force -AllowClobber -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Get-ScriptDirectory {
    try { Split-Path -Path $PSCommandPath -Parent -ErrorAction Stop }
    catch { [Environment]::GetFolderPath("Desktop") }
}

function VerifyApps {
    $raw = winget list --accept-source-agreements | Out-String
    $lines = $raw -split "`n" | Where-Object { $_ -match '^\S' }
    $apps = foreach ($line in $lines) {
        $c = $line -split '\s{2,}'
        if ($c.Count -ge 3) { [pscustomobject]@{ Name=$c[0].Trim(); ID=$c[1].Trim(); Version=$c[2].Trim(); Source=$c[3].Trim() } }
    }
    return $apps
}

MainMenu
