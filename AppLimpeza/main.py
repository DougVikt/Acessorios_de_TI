import subprocess as sbp
import pyautogui
from pywinauto import Application
import os
import shutil
import psutil
import pygetwindow as gw
import tkinter as tk
from tkinter import messagebox , ttk
import time
from version import __version__ 


class AppCleaner:
    def __init__(self):
        self.tkr = tk.Tk()
        self.tkr.withdraw()  # Esconde a janela principal do Tkinter     
                
    def window_main(self,text:str , title = "TI Clean",close = False):
        try :
            # Cria uma janela principal 
            window_box = tk.Toplevel()
            window_box.title(title)
            window_box.geometry("300x150")
            window_box.configure(bg="gray")
            window_box.overrideredirect(True)
            label_version = ttk.Label(
                window_box,text=f"V {__version__}",background='gray'
            )
            label_version.pack()
            label = ttk.Label( 
                window_box, text=text, background="gray",fg="gold",padx=30,
                pady=30,font=("Helvetica", 14)
            ) # janela de inicio
            label.pack()
            if close:
                window_box.geometry("300x200")
                button = ttk.Button( 
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
                
    # def window_main(self, text , close=False):
        try :
            # Cria uma janela com a mensagem 
            self.tkr.title("TI Clean")
            self.tkr.geometry("210x100")
            self.tkr.configure(bg="gray")
            self.tkr.overrideredirect(True)
            label_version = self.ttk.Label(
                self.tkr,text=f"V {self.version}",background='gray'
            )
            label_version.pack()
            label = self.ttk.Label( 
                self.tkr, text=text, background="gray",fg="gold",padx=30,
                pady=30,font=("Helvetica", 16)
            ) # janela de inicio
            label.pack()
            if close:
                self.tkr.geometry("210x150")
                button = self.ttk.Button( 
                    self.tkr, text="Fechar", command=self.tkr.destroy ,bg="red", 
                    fg="black" ,font=("Helvetica", 12),borderwidth=2, relief="ridge",
                    padx=20
                ) # botão para fechar 
                button.pack()
            else :
                self.tkr.after(3000, self.tkr.destroy)
                
            self.tkr.mainloop()
        except Exception as e :
            return self._erro_message(f"Erro na criação da janela principal: {e}")
        
        
    def disk_clear(self):
        try:
            sbp.run(["cleanmgr.exe", "/sageget:1"] , shell=False , check=False)  # Abre o Disk Cleanup
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
                    return self._erro_message(f"Erro de execução: {e}")
        except (self.sbp.SubprocessError , self.psutil.Error ) as e :
            return self._erro_message(f"Erro de iniciação do clean : {e}")
            
    def delete_Temp(self):

        # pega o nome do usuário e do drive que o usuário está usando
        user_name = self.os.getlogin()
        drive_name = self.os.path.splitdrive(self.os.getcwd())[0]

        path_temp = f'{drive_name}/Users/{user_name}/AppData/Local/Temp/'
        # abre a pasta Temp do usuário logado no explorer
        self.os.startfile(path_temp) 
        # da um tempo para abrir a pasta
        time.sleep(2)
        for filemane in self.os.listdir(path_temp):# lista os arquivos da pasta Temp
            try:
                filepath = self.os.path.join(path_temp, filemane) # junta o caminho com o nome do arquivo
                # verifica se é um arquivo
                if self.os.path.isfile(filepath) or self.os.path.islink(filepath):
                    # deleta o arquivo
                    self.os.unlink(filepath)
                
                # verifica se é um diretório
                elif self.os.path.isdir(filepath):
                    # deleta o diretório com tudo dentro
                    self.shutil.rmtree(filepath)
                
            except Exception as e:
                return self._erro_message(f'\nErro ao deletar o arquivo {filepath} : {e}')
            
            time.sleep(0.3)
            
    def main(self):
        try:
            self.window_main("INICIANDO LIMPEZA ...")
            time.sleep(1)
            self.delete_Temp()
            time.sleep(2)
             # fecha a pasta Temp
            for window in gw.getWindowsWithTitle('Temp'):
                window.close()  
            open=self.disk_clear()
            if open:
                time.sleep(10)
                self.window_main("TUDO LIMPO",close=True)
        except Exception as e:
            return self._erro_message(f"Erro na execução principal: {e}")
            
    
    # Mensagem de erro exibido em tela
    def _erro_message(self, error_message):
        return messagebox.showerror("Erro", error_message)
    
        
            

if __name__ == "__main__":
    
    ti_clean = AppCleaner()
    ti_clean.main()
   
    