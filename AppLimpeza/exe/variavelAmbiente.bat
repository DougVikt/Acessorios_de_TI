@echo on
setlocal

:: Defina o diretório que você deseja adicionar ao PATH
set "NOVO_DIR=C:\Program Files (x86)\TiClean\ticlean.exe"

:: Verifica se o diretório já está no PATH
echo %PATH% | find /I "%NOVO_DIR%" >nul
if %errorlevel%==0 (
    echo O diretório já está no PATH.
) else (
    :: Adiciona o diretório ao PATH do usuário
    setx PATH "%PATH%;%NOVO_DIR%"
    echo O diretório foi adicionado ao PATH.
)

endlocal
pause