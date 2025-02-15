import subprocess
import pyautogui
import pygetwindow as gw
import psutil
import time

def disk_clear():
    subprocess.Popen(["cleanmgr.exe", "/sageget:1"], )  # Abre o Disk Cleanup
    # Verifica se o Disk Cleanup está aberto
    for process in psutil.process_iter(['pid', 'name']):
        if process.info['name'] == "cleanmgr.exe":
            open = True
            break
    time.sleep(7)
    if open: 
        # Traz a janela do Disk Cleanup para o primeiro plano
        windows = gw.getWindowsWithTitle('Disk Cleanup')
        if windows:
            windows[0].activate()
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
                                    
   
 

