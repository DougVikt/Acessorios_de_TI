@Echo Off
mode 60,5
chcp 65001 >nul
title Instalar programas

call :VerPrevAdmin
if "%Admin%"=="ops" goto :eof

title WinGet - Pós-instalador - Feito por @DuanyDias

if exist "%temp%\ilst.txt" del /q /f "%temp%\ilst.txt"
if exist "%temp%\sLilst.txt" del /q /f "%temp%\sLilst.txt"
if exist "%temp%\wgLista.txt" del /q /f "%temp%\wgLista.txt"
if exist "%temp%\wgLista64.txt" del /q /f "%temp%\wgLista64.txt"

setlocal EnableDelayedExpansion

for /f "tokens=6 delims=[]. " %%b in ('ver') do set wbld=%%b
if %wbld% LSS 17134 cls & echo. & echo. & echo     A versão do Windows não é compatível com o WinGET. & timeout /t 5 /nobreak >nul & Exit
cls
chcp 65001 >nul
if exist "%WinDir%\SysWOW64" (set "archs=x64") else (set "archs=x86")
set wgtVer=
if %archs%.==x86. (
 set "wglist=%~dp0wgLista.txt"
 set "_wglist=%temp%\wgLista.txt"
)
if %archs%.==x64. (
 set "wglist=%~dp0wgLista64.txt"
 set "_wglist=%temp%\wgLista64.txt"
)
if not exist "%wglist%" goto End
xcopy /qy "%wglist%" "%temp%\" >nul
timeout /t 2 /nobreak >nul
ren "%_wglist%" ilst.txt
set WGilst=%temp%\ilst.txt
set WGsLilst=%temp%\sLilst.txt
for /f "tokens=1-3 delims=v." %%i in ('winget -v 2^>nul') do set "wgtVer=%%i.%%j.%%k"
if "%wgtVer%"=="" goto instWGt
if %wgtVer% GEQ 1.7 goto instprog

:instWGt
cls
chcp 850 >nul
if %archs%.==x64. goto XamlVlbsX64
if %archs%.==x86. goto XamlVlbsX86

:XamlVlbsX64
powershell -ExecutionPolicy ByPass -Command "& {$LINKA = \"https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.8.6.nupkg\"; Invoke-WebRequest -Uri $LINKA -OutFile \"SetupXaml.zip\" -UseBasicParsing; Expand-Archive \"SetupXaml.zip\"; Clear-Host; Add-AppxPackage -Path \"SetupXaml\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx\"; Remove-Item \"SetupXaml.zip\"; Remove-Item \"SetupXaml\" -Recurse; Clear-Host; $LINKB = \"https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx\"; Invoke-WebRequest -Uri $LINKB -OutFile \"VCLibs_x64.appx\" -UseBasicParsing; Add-AppxPackage -Path \"VCLibs_x64.appx\"; Remove-Item \"VCLibs_x64.appx\"}"
goto iWPkgMgr

:XamlVlbsX86
powershell -ExecutionPolicy ByPass -Command "& {$LINKA = \"https://globalcdn.nuget.org/packages/microsoft.ui.xaml.2.8.6.nupkg\"; Invoke-WebRequest -Uri $LINKA -OutFile \"SetupXaml.zip\" -UseBasicParsing; Expand-Archive \"SetupXaml.zip\"; Clear-Host; Add-AppxPackage -Path \"SetupXaml\tools\AppX\x86\Release\Microsoft.UI.Xaml.2.8.appx\"; Remove-Item \"SetupXaml.zip\"; Remove-Item \"SetupXaml\" -Recurse; Clear-Host; $LINKB = \"https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx\"; Invoke-WebRequest -Uri $LINKB -OutFile \"VCLibs_x86.appx\" -UseBasicParsing; Add-AppxPackage -Path \"VCLibs_x86.appx\"; Remove-Item \"VCLibs_x86.appx\"}"

:iWPkgMgr
cls
powershell -ExecutionPolicy ByPass -Command "& {$URL = \"https://api.github.com/repos/microsoft/winget-cli/releases/latest\"; $URL = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content | ConvertFrom-Json | Select-Object -ExpandProperty \"assets\" | Where-Object \"browser_download_url\" -Match '.msixbundle' | Select-Object -ExpandProperty \"browser_download_url\"; Clear-Host; Invoke-WebRequest -Uri $URL -OutFile \"Setup.msix\" -UseBasicParsing; Clear-Host; Add-AppxPackage -Path \"Setup.msix\"; Remove-Item \"Setup.msix\"}"

:instprog
cls
mode 120,12
chcp 65001 >nul
findstr /i /v "#" "%WGilst%">"%WGsLilst%"
del /Q /F "%WGilst%" >nul 2>&1
ren "%WGsLilst%" ilst.txt
timeout /t 3 /nobreak >nul
set i_progs=0
for /f "tokens=* delims=" %%# in ('type "%WGilst%"') do (
  set /a i_progs=i_progs+1
  set instprog[!i_progs!]=%%#
)
for /l %%i in (1,1,!i_progs!) do (
  cls
  echo.
  winget install --id=!instprog[%%i]! -e --accept-package-agreements --accept-source-agreements
  timeout /t 1 /nobreak >nul
)
cls
mode 70,5
echo.
echo.
echo     Concluído
timeou 5 >nul
start "" "https://cutt.ly/Swh2uy0b"
start "" "https://www.youtube.com/@xerifetech?sub_confirmation=1"
Exit

:End
cls
mode 70,5
chcp 65001 >nul
echo.
echo.
echo     A lista com os ID dos programas não foi encontrada.
cls
del /Q /F "%WGilst%" >nul 2>&1
timeout /t 5 /nobreak >nul
Exit

:ElevAdmin
echo Set UAC = CreateObject^("Shell.Application"^) >"%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >>"%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
goto Admin & Exit /b

:Admin
if exist "%temp%\getadmin.vbs" (del "%temp%\getadmin.vbs") & pushd "%CD%" & cd /d "%~dp0" & Exit

:VerPrevAdmin
fsutil dirty query %systemdrive% >nul
if not errorLevel 1 (
 mode 80,8
 ) else (
   goto ElevAdmin & echo. & set "Admin=ops"
)
goto :eof
