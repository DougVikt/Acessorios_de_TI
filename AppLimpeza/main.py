import pygetwindow as gw
from delete_temp import delete_Temp

if __name__ == "__main__":
    delete_Temp()
     # fecha a pasta Temp
    for window in gw.getWindowsWithTitle('Temp'):
        window.close()   
