import tkinter as tk
from tkinter import messagebox , ttk
import time
from version import __version__

class AppCleaner:
    def __init__(self):
        self.tkr = tk.Tk()
        self.tkr.withdraw()  # Esconde a janela principal do Tkinter     
                
    def window_main(self,text:str , title = "TI Clean",close = True):
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
            print("ok")
            label_version.pack()
            label = tk.Label( 
                window_box, text=text, background="gray",fg="gold",padx=30,
                pady=30,font=("Helvetica", 14)
            ) # janela de inicio
            label.pack()
            print("ok2")
            if close:
                window_box.geometry("300x200")
                button = tk.Button( 
                    window_box, text="Fechar", command=window_box.destroy ,bg="red", 
                    fg="black" ,font=("Helvetica", 12),borderwidth=2, relief="ridge",
                    padx=20
                ) # botão para fechar 
                button.pack()
                print("ok3")
            else :
                window_box.after(3000, window_box.destroy)
                
            window_box.mainloop()
        except Exception as e :
            return print(f"Erro na criação da janela de mensagem: {e}")
                
                
                
if __name__ == "__main__":
    
    ti_clean = AppCleaner()
    ti_clean.window_main("Aplicação iniciada com sucesso!")
   