import pygetwindow as gw
import tkinter as ttk
import time
from delete_temp import delete_Temp
from window import window_main
from disk_clear import disk_clear



if __name__ == "__main__":
    window_main(ttk,"INICIANDO...")
    time.sleep(1)
    delete_Temp()
    time.sleep(2)
     # fecha a pasta Temp
    for window in gw.getWindowsWithTitle('Temp'):
        window.close()  
    open=disk_clear()
    print(open)
    if open:
        time.sleep(5)
        window_main(ttk,"TUDO LIMPO", close=True)
   
    
     
