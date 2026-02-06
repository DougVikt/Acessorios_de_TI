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


class AppCleaner:
    def __init__(self):
        self.root = tk.Tk()

                
    def window_main(self,text:str , title = "TI Clean",close = False):
        try :
            # Cria uma janela principal 
            window_box = self.root
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
                pady=30,font=("Helvetica", 14)
            ) # janela de inicio
            label.pack()
            if close:
                window_box.geometry("300x200")
                button = tk.Button( 
                    window_box, text="Fechar", command=window_box.destroy ,bg="red", 
                    fg="black" ,font=("Helvetica", 12),borderwidth=2, relief="ridge",
                    padx=20
                ) # botão para fechar 
                button.pack()
            else :
                window_box.after(3000, window_box.destroy)
                
            window_box.mainloop()
        except Exception as e :
            return self._erro_message(f"Erro na criação da janela de mensagem: {e}")       
                
        
        
    def disk_clear(self):
        try:
            sbp.run(["cleanmgr.exe", "/sageget:1"] , check=False)  # Abre o Disk Cleanup
            # Verifica se o Disk Cleanup está aberto
            pid = None      
            for process in psutil.process_iter(['pid', 'name']):
                if process.info['name'].lower() == "cleanmgr.exe":
                    pid = process.info['pid']
                    finished = True
                    print("pass interno")
                    break
            
            if not pid:
                return False, self._erro_message("Cleanmgr não abriu")
            
            time.sleep(4)
            if finished: 
                print(f"pass interno {finished}")
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
                    return finished
                except Exception as e :
                    self._erro_message(f"Erro de execução: {e}")
                    return False
        except (sbp.SubprocessError , psutil.Error ) as e :
            return self._erro_message(f"Erro de iniciação do clean : {e}")
            
    def delete_Temp(self):
        try:
            temp_path = Path(os.getenv('TEMP'))  # usa o Path para obter o caminho da pasta Temp
            os.startfile(str(temp_path))
            time.sleep(2)
            shutil.rmtree(temp_path, ignore_errors=True) # deleta a pasta Temp e todo o seu conteúdo ignorando erros
            time.sleep(2)
        except Exception as e:
            self._erro_message(f"Erro ao executar limpeza da pasta Temp: {e}")
     
            
    def main(self):
        try:
            self.window_main("INICIANDO LIMPEZA ...")
            print("pass")
            time.sleep(1)
            print("pass")
            self.delete_Temp()
            print("pass")
            time.sleep(2)
             # fecha a pasta Temp
            print("pass")
            for window in gw.getWindowsWithTitle('Temp'):
                window.close()  
                print("pass")
            finished_cleaning = self.disk_clear()
            print("pass")
            if finished_cleaning:
                print("pass")
                time.sleep(10)
                print("pass")
                self.window_main("TUDO LIMPO",close=True)
                print("pass")
            else:
                print("pass")
                self._erro_message("FALHA AO ABRIR O DISK CLEANUP")
                print("pass")
        except Exception as e:
            return self._erro_message(f"Erro na execução principal: {e}")
            
    
    # Mensagem de erro exibido em tela
    def _erro_message(self, error_message):
        return messagebox.showerror("Erro", error_message)
    
        
            

if __name__ == "__main__":
    
    ti_clean = AppCleaner()
    ti_clean.main()
   
    