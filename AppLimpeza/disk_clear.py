import subprocess as sbp
import pyautogui
from pywinauto import Application
import psutil
import time
from logs import register_logs

def disk_clear():
    try:
        sbp.Popen(["cleanmgr.exe", "/sageget:1"], shell=False )  # Abre o Disk Cleanup
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
                app = Application(backend='win32').connect(process=pid)
                dlg = app.window(title_re='.*Limpeza.*|.*Cleanup.*')
                dlg.wait('visible ready', timeout=15)
                dlg.set_focus()  # Traz a janela para o primeiro plano
                list_itens = dlg.child_window(class_name="SysListView32",found_index=0) 
                list_itens.wait('visible', timeout=10)                                    
                for n in range(list_itens.item_count()):  # Loop para navegar nas opções do Disk Cleanup
                   marked = list_itens.is_checked(n) # Verifica se o item já está marcado
                   if not marked:
                       list_itens.check(n)  # Marca todas as opções para exclusão
                time.sleep(3)
                pyautogui.press("enter") # Confirma a exclusão dos arquivos                                                                                 
                time.sleep(3)
                pyautogui.press("enter") 
                return open
            except Exception as e :
                register_logs(f"LOG - Erro de execução: {e}")
    except (sbp.SubprocessError , psutil.Error ) as e :
        register_logs(f"LOG - Erro de iniciação do clean : {e}")

disk_clear()