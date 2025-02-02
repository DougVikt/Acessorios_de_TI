import pygetwindow as gw
import time
from delete_temp import delete_Temp

if __name__ == "__main__":
    delete_Temp()
    time.sleep(2)
     # fecha a pasta Temp
    for window in gw.getWindowsWithTitle('Temp'):
        window.close()   
