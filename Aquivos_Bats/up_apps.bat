@echo off

rem BY DOUGVIKT
rem GitHub: DOUGVIKT

mode con cols=70 lines=40
title UP APPS

echo		                     INICIANDO ... 

rem COMANDO DE ATUALIZAÇÃO
echo y | winget upgrade 

rem COMANDO DE ATIALIZAÇÃO DE TODOS OS PACOTES 
winget upgrade --all

rem FIM DAS ATUALIZAÇÕES 
cls
echo ============================ FINALIZADO ==============================
pause
