import subprocess as sbp
import pyautogui
from pywinauto import Application
import psutil
import time
from logs import register_logs

def disk_clear():
    try:
        sbp.Popen(["cleanmgr.exe", "/sageget:1"], )  # Abre o Disk Cleanup
        # Verifica se o Disk Cleanup está aberto
        for process in psutil.process_iter(['pid', 'name']):
            if process.info['name'] == "cleanmgr.exe":
                pid = process.info['pid']
                open = True
                break
        time.sleep(7)
        if open: 
            try: 
                # Usando pywinauto para trazer a janela para o primeiro plano
                app = Application().connect(process=pid)
                dlg = app.window(title_re='.*Limpeza.*|.*Cleanup.*')
                dlg.set_focus()  # Traz a janela para o primeiro plano
                dlg.minimize()  # Minimiza a janela
                dlg.restore()  # Restaura a janela , garnatir que a janela está no primeiro plano
                time.sleep(3)                                                        
                for n in range(6):  # Loop para navegar nas opções do Disk Cleanup
                    pyautogui.press("down")  # Move o cursor para baixo
                    time.sleep(0.3)
                    if n > 1 : # so marca depois dos 2 primeiros
                        pyautogui.press("space")  
                pyautogui.press("enter") # Confirma a exclusão dos arquivos                                                                                 
                time.sleep(2)
                pyautogui.press("enter") 
                return open
            except Exception as e :
                register_logs(f"LOG - Erro de execução: {e}")
    except (sbp.SubprocessError , psutil.Error ) as e :
        register_logs(f"LOG - Erro de iniciação do clean : {e}")

