@echo off 
rem by DougVikt

mode con cols=50 lines=25
title LIMPEZA GERAL

color 70
:menu
cls
echo 		MENU DE COMANDOS
echo.
echo 1- Limpeza temporarios 
echo 2- Limpeza de disco
echo 3- Verificar arquivos corrumpidos sistema
echo 4- Verificar arquivos geral
echo 5- Sair 
echo.
choice /c 12345 /n /m " Digite uma numero :" 

if errorlevel 5 goto :eof
if errorlevel 4 goto comando4
if errorlevel 3 goto comando3
if errorlevel 2 goto comando2
if errorlevel 1 goto comando1

:comando1
rem start "%temp%"
rem timeout /nobreak /t 5 >nul  
del /q /s /f %temp%\*.* 2>nul
pause
goto menu

:comando2
schtasks /run /tn "\Microsoft\Windows\DiskCleanup\SilentCleanup" & cleanmgr /sagerun:65535
pause
goto menu

:comando3
sfc /scannow
pause
goto menu

:comando4
echo s | chkdsk C: /f
pause
goto menu