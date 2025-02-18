import pygetwindow as gw
import tkinter as ttk
import time
import xml.etree.ElementTree as xee
from delete_temp import delete_Temp
from window import window_main
from disk_clear import disk_clear

def app_version():
    # verificar a versão 
    xml= xee.parse('manifest.xml')
    root = xml.getroot()
    version = root.find('version').text
    return version

if __name__ == "__main__":
    version = app_version()
    window_main(ttk,"INICIANDO..." , version=version)
    time.sleep(1)
    delete_Temp()
    time.sleep(2)
     # fecha a pasta Temp
    for window in gw.getWindowsWithTitle('Temp'):
        window.close()  
    open=disk_clear()
    if open:
        time.sleep(10)
        window_main(ttk,"TUDO LIMPO",version, close=True)
   
    
     
# python -m auto_py_to_exe 