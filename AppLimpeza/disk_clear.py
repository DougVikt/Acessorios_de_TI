import subprocess
import pyautogui
import psutil
import time

def disk_clear():
    subprocess.Popen(["cleanmgr.exe", "/sageget:1"], )  # Abre o Disk Cleanup
    # Verifica se o Disk Cleanup está aberto
    for process in psutil.process_iter(['pid', 'name']):
        if process.info['name'] == "cleanmgr.exe":
            open = True
            break
    time.sleep(10)
    if open: 
        time.sleep(5)                                                        
        for _ in range(7):  # Loop para navegar nas opções do Disk Cleanup
            pyautogui.press("down")  # Move o cursor para baixo
            time.sleep(0.3)
            pyautogui.press("space")  
        pyautogui.press("enter") # Confirma a exclusão dos arquivos                                                                                 
        time.sleep(2)
        pyautogui.press("enter") 
        return open
                                        