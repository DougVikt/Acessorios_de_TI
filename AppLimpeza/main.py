import pygetwindow as gw
import tkinter as ttk
import time
from delete_temp import delete_Temp
from window import window_main
from disk_clear import disk_clear
from version import __version__ 


if __name__ == "__main__":
    
    window_main(ttk,"INICIANDO..." , version=__version__)
    time.sleep(1)
    delete_Temp()
    time.sleep(2)
     # fecha a pasta Temp
    for window in gw.getWindowsWithTitle('Temp'):
        window.close()  
    open=disk_clear()
    if open:
        time.sleep(10)
        window_main(ttk,"TUDO LIMPO",version=__version__, close=True)
   
    