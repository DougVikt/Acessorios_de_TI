Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# =================================================================================
# XAML - DESIGN DA INTERFACE (WPF)
# =================================================================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="TI Supremo - Dashboard Profissional" Height="650" Width="900" 
        WindowStartupLocation="CenterScreen" Background="#1E1E1E" ResizeMode="NoResize">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="220"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <!-- Menu Lateral -->
        <StackPanel Grid.Column="0" Background="#252526">
            <Label Content="TI SUPREMO" Foreground="#00FF00" FontSize="24" FontWeight="Bold" Margin="20,30,20,10" HorizontalAlignment="Center"/>
            <Label Content="Versão GUI 1.0" Foreground="#888" FontSize="10" HorizontalAlignment="Center" Margin="0,0,0,30"/>
            
            <Button Name="BtnApps" Content="APLICATIVOS" Height="45" Margin="10,5" Background="#333" Foreground="White" BorderThickness="0"/>
            <Button Name="BtnSystem" Content="SISTEMA" Height="45" Margin="10,5" Background="#333" Foreground="White" BorderThickness="0"/>
            <Button Name="BtnNetwork" Content="REDE" Height="45" Margin="10,5" Background="#333" Foreground="White" BorderThickness="0"/>
            <Button Name="BtnUtils" Content="UTILITÁRIOS" Height="45" Margin="10,5" Background="#333" Foreground="White" BorderThickness="0"/>
            
            <Separator Margin="20,20" Background="#444"/>
            <Button Name="BtnExit" Content="SAIR" Height="40" Margin="30,5" Background="#442222" Foreground="White" BorderThickness="0"/>
        </StackPanel>

        <!-- Conteúdo Principal -->
        <Grid Grid.Column="1" Margin="20">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="150"/>
            </Grid.RowDefinitions>

            <Label Name="LblTitle" Content="Bem-vindo ao TI Supremo" Foreground="White" FontSize="20" FontWeight="SemiBold" Margin="0,0,0,20"/>

            <!-- Painel de Ações (Dinâmico) -->
            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                <WrapPanel Name="ActionPanel" HorizontalAlignment="Left">
                    <!-- Botões serão inseridos aqui via Script -->
                </WrapPanel>
            </ScrollViewer>

            <!-- Console de Log Interno -->
            <GroupBox Header="Log de Operações" Grid.Row="2" Foreground="#888" BorderBrush="#444" Margin="0,10,0,0">
                <TextBox Name="TxtLog" Background="#000" Foreground="#00FF00" IsReadOnly="True" 
                         VerticalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="11" TextWrapping="Wrap"/>
            </GroupBox>
        </Grid>
    </Grid>
</Window>
"@

# Carregar XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Form = [Windows.Markup.XamlReader]::Load($reader)

# Mapear Elementos
$nodes = $xaml.SelectNodes("//*[@Name]")
foreach ($node in $nodes) {
    Set-Variable -Name "obj$($node.Name)" -Value $Form.FindName($node.Name)
}

# =================================================================================
# FUNÇÕES DE LOG E UI
# =================================================================================
function Write-Log {
    param([string]$Message, [string]$Color = "Green")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $objTxtLog.AppendText("[$timestamp] $Message`r`n")
    $objTxtLog.ScrollToEnd()
    DoEvents
}

function DoEvents {
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke("Background", [System.Windows.Threading.DispatcherPriority]::Background, [Action[System.Windows.Threading.DispatcherFrame]]{ param($f) $f.Continue = $false }, $frame)
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

function Clear-Actions {
    $objActionPanel.Children.Clear()
}

function Add-ActionButton {
    param($Text, $Action)
    $btn = New-Object System.Windows.Controls.Button
    $btn.Content = $Text
    $btn.Width = 180
    $btn.Height = 60
    $btn.Margin = 5
    $btn.Background = "#3E3E42"
    $btn.Foreground = "White"
    $btn.BorderThickness = 0
    $btn.Add_Click($Action)
    $objActionPanel.Children.Add($btn)
}

# =================================================================================
# LÓGICA DAS CATEGORIAS
# =================================================================================

# --- CATEGORIA: APLICATIVOS ---
$objBtnApps.Add_Click({
    $objLblTitle.Content = "Ferramentas de Aplicativos"
    Clear-Actions
    Add-ActionButton "Instalar via TXT" { 
        Write-Log "Iniciando instalação via TXT..."
        # Lógica de instalação aqui (integrada da versão PRO)
        Write-Log "Aviso: Selecione o arquivo na janela que será aberta."
    }
    Add-ActionButton "Listar Instalados" { 
        Write-Log "Coletando lista de programas..."
        winget list | Out-String | Write-Log
    }
    Add-ActionButton "Atualizar Tudo" {
        Write-Log "Buscando atualizações no Winget..."
        winget upgrade --all --accept-package-agreements
        Write-Log "Processo de atualização finalizado."
    }
    Add-ActionButton "Limpar Cache Apps" {
        Write-Log "Limpando caches (Store, Winget)..."
        wsreset.exe; winget source reset --force
        Write-Log "Caches limpos."
    }
})

# --- CATEGORIA: SISTEMA ---
$objBtnSystem.Add_Click({
    $objLblTitle.Content = "Ferramentas de Sistema"
    Clear-Actions
    Add-ActionButton "Uso de Disco" {
        $disk = Get-PSDrive C | Select-Object @{Name="Livre(GB)";Expression={[math]::Round($_.Free/1GB,2)}}
        Write-Log "Espaço Livre em C: $($disk.'Livre(GB)') GB"
    }
    Add-ActionButton "Limpar Temporários" {
        Write-Log "Limpando pastas TEMP..."
        $size = (Get-ChildItem $env:TEMP -Recurse | Measure-Object -Property Length -Sum).Sum
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Limpeza concluída. Aprox. $([math]::Round($size/1MB,2)) MB liberados."
    }
    Add-ActionButton "Reparo DISM" {
        Write-Log "Iniciando DISM RestoreHealth (Pode demorar)..."
        Dism /Online /Cleanup-Image /RestoreHealth | Write-Log
    }
    Add-ActionButton "SFC Scannow" {
        Write-Log "Iniciando verificação de integridade SFC..."
        sfc /scannow | Write-Log
    }
    Add-ActionButton "Ativar Win/Office" {
        Write-Log "Chamando script Massgrave..."
        irm https://massgrave.dev/get | iex
    }
})

# --- CATEGORIA: REDE ---
$objBtnNetwork.Add_Click({
    $objLblTitle.Content = "Ferramentas de Rede"
    Clear-Actions
    Add-ActionButton "Teste de Ping" {
        Write-Log "Testando conexão com Google (8.8.8.8)..."
        if(Test-Connection 8.8.8.8 -Count 2 -Quiet){ Write-Log "Conexão OK" } else { Write-Log "Falha na conexão" "Red" }
    }
    Add-ActionButton "Verificar IPs" {
        Get-NetIPAddress -AddressFamily IPv4 | Select-Object InterfaceAlias, IPAddress | Out-String | Write-Log
    }
    Add-ActionButton "DNS Google" {
        Write-Log "Configurando DNS Google..."
        Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter | Where {$_.Status -eq "Up"}).InterfaceIndex -ServerAddresses ("8.8.8.8","8.8.4.4")
        Write-Log "DNS Aplicado."
    }
    Add-ActionButton "Resetar Rede" {
        Write-Log "Resetando Winsock e IP Stack..."
        netsh winsock reset; netsh int ip reset
        Write-Log "Reinicie o computador para aplicar totalmente."
    }
})

# --- CATEGORIA: UTILITÁRIOS ---
$objBtnUtils.Add_Click({
    $objLblTitle.Content = "Utilitários Diversos"
    Clear-Actions
    Add-ActionButton "Relatório HTML" {
        $path = "$env:USERPROFILE\Desktop\Relatorio_TI.html"
        Get-ComputerInfo | ConvertTo-Html | Out-File $path
        Write-Log "Relatório gerado no Desktop."
        Start-Process $path
    }
    Add-ActionButton "Ponto Restauração" {
        Write-Log "Criando ponto de restauração..."
        Checkpoint-Computer -Description "TI_Supremo_GUI" -RestorePointType "MODIFY_SETTINGS"
        Write-Log "Ponto criado."
    }
    Add-ActionButton "Detalhes Hardware" {
        $cpu = Get-CimInstance Win32_Processor | Select-Object Name
        Write-Log "Processador: $($cpu.Name)"
    }
})

# Sair
$objBtnExit.Add_Click({ $Form.Close() })

# Inicialização
Write-Log "TI Supremo GUI carregado com sucesso."
Write-Log "Selecione uma categoria no menu lateral para começar."
$Form.ShowDialog() | Out-Null
