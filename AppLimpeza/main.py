import pygetwindow as gw
import tkinter as ttk
import time
from delete_temp import delete_Temp
from window import window_main



if __name__ == "__main__":
    window_main(ttk,"INICIANDO...")
    time.sleep(1)
    delete_Temp()
    time.sleep(2)
     # fecha a pasta Temp
    for window in gw.getWindowsWithTitle('Temp'):
        window.close()  
    window_main(ttk,"TUDO LIMPO", close=True)
   
    
     
