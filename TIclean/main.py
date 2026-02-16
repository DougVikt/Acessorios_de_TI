import time
import pyautogui
import os
import shutil
import psutil
import pygetwindow as gw
import tkinter as tk
import subprocess as sbp
from tkinter import messagebox
from pywinauto import Application
from pathlib import Path
from version import __version__ 

"""
APP DE LIMPEZA DE TEMPORARIOS E LIMPEZA DE DISCO AUTOMATIZADA 
"""
                
def window_main(text:str , title = "TI Clean",close = False):
    try :
        # Cria uma janela principal 
        window_box = tk.Tk()
        window_box.title(title)
        window_box.geometry("300x150")
        window_box.configure(bg="gray")
        window_box.overrideredirect(True)
        label_version = tk.Label(
            window_box,text=f"V {__version__}",background='gray'
        )
        label_version.pack()
        label = tk.Label( 
            window_box, text=text, background="gray",fg="gold",padx=30,
            pady=30,font=("Helvetica", 16)
        ) # janela de inicio
        label.pack()
        if close:
            window_box.geometry("300x200")
            button = tk.Button( 
                window_box, text="Fechar", command=window_box.destroy ,bg="red", 
                fg="black" ,font=("Helvetica", 14),borderwidth=2, relief="ridge",
                padx=20
            ) # botão para fechar 
            button.pack()
        else :
            window_box.after(3000, window_box.destroy)
            
        window_box.mainloop()
    except Exception as e :
        return erro_message(f"Erro na criação da janela de mensagem: {e}")       
                
   
    
def disk_clear():
    try:      
        sbp.Popen(["cleanmgr.exe", "/sageget:1"] )  # Abre o Disk Cleanup
        time.sleep(3)
        # Verifica se o Disk Cleanup está aberto
        pid = None      
        for process in psutil.process_iter(['pid', 'name']): # verifica cada processo 
            if process.info['name'] == "cleanmgr.exe":
                pid = process.info['pid']
                is_open = True
                break
        
        if not pid:
            return False, erro_message("Cleanmgr não abriu")
        
        time.sleep(3)
        if is_open: 
            try:   
                # Usando pywinauto para trazer a janela para o primeiro plano
                app = Application(backend='win32').connect(process=pid)
                dlg = app.window(title_re='.*Limpeza.*|.*Cleanup.*')
                dlg.wait('visible ready', timeout=15)
                dlg.set_focus()  # Traz a janela para o primeiro plano
                list_itens = dlg.child_window(class_name="SysListView32",found_index=0) 
                list_itens.wait('visible', timeout=10)                                  
                for n in range(list_itens.item_count()):  # Loop para navegar nas opções do Disk Cleanup
                    if not list_itens.is_checked(n): # Verifica se o item já está marcado
                        list_itens.check(n)  # Marca todas as opções para exclusão
                time.sleep(3)
                pyautogui.press("enter") # Confirma a exclusão dos arquivos                                                                                 
                time.sleep(3)
                pyautogui.press("enter")
                try : 
                    # Aguarda o processo cleanmgr.exe finalizar (máximo 300 segundos/5 minutos)
                    pross = psutil.Process(pid)
                    pross.wait(timeout=300)
                    return True
                except psutil.NoSuchProcess:
                    # Processo não encontrado, mas considera limpeza bem-sucedida
                    return True
                except psutil.TimeoutExpired:
                    # Timeout ao aguardar finalização do processo
                    return False
            except Exception as e :
                # Erro durante execução do Disk Cleanup
                erro_message(f"Erro de execução: {e}")
                return False
        else :
            # Processo cleanmgr.exe não estava aberto
            return False
    except (sbp.SubprocessError , psutil.Error ) as e :
        # Erro ao iniciar ou gerenciar o processo cleanmgr.exe
        return erro_message(f"Erro de iniciação do clean : {e}")
            
            
def delete_Temp():
    try:
        temp_path = Path(os.getenv('TEMP'))  # usa o Path para obter o caminho da pasta Temp
        os.startfile(str(temp_path))
        time.sleep(2)
        for item in temp_path.iterdir():
            time.sleep(0.5)
            try:
                if item.is_dir():
                    shutil.rmtree(item, ignore_errors=True)
                else:
                    item.unlink(missing_ok=True)
            except Exception:
                pass
    except Exception as e:
        erro_message(f"Erro ao executar limpeza da pasta Temp: {e}")  
       

# Mensagem de erro exibido em tela
def erro_message(error_message):
    return messagebox.showerror("Erro", error_message)

    
            
delete_Temp()
if __name__ == "__main__":
    try:
        window_main("INICIANDO LIMPEZA ...")
        time.sleep(3)
        delete_Temp()
        time.sleep(2)
        # fecha a pasta Temp
        for window in gw.getWindowsWithTitle('Temp'):
            window.close()  

        finished_cleaning = disk_clear()
        if finished_cleaning:
            time.sleep(7)
            window_main("TUDO LIMPO",close=True)
        else:
            erro_message("FALHA AO ABRIR O DISK CLEANUP")

    except Exception as e:
        erro_message(f"Erro na execução principal: {e}")