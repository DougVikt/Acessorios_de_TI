import os 
import shutil
import time


def delete_Temp():

    # pega o nome do usuário e do drive que o usuário está usando
    user_name = os.getlogin()
    drive_name = os.path.splitdrive(os.getcwd())[0]

    path_temp = f'{drive_name}/Users/{user_name}/AppData/Local/Temp/'
    # abre a pasta Temp do usuário logado no explorer
    os.startfile(path_temp) 
    # da um tempo para abrir a pasta
    time.sleep(2)
    for filemane in os.listdir(path_temp):# lista os arquivos da pasta Temp
        try:
            filepath = os.path.join(path_temp, filemane) # junta o caminho com o nome do arquivo
            # verifica se é um arquivo
            if os.path.isfile(filepath) or os.path.islink(filepath):
                # deleta o arquivo
                os.unlink(filepath)
            
            # verifica se é um diretório
            elif os.path.isdir(filepath):
                # deleta o diretório com tudo dentro
                shutil.rmtree(filepath)
            
        except Exception as e:
            return print(f'\nErro ao deletar o arquivo {filepath} : {e}')
        
        time.sleep(0.3)
    
    



from pathlib import Path
import shutil

def delete_Temp_pro():
    try:
        temp_path = Path(os.getenv('TEMP'))  # Mais direto que construir manualmente
        os.startfile(str(temp_path))
        time.sleep(2)
        shutil.rmtree(temp_path, ignore_errors=True)
        print(" Temp limpa com segurança!")
    except Exception as e:
        print(f"Erro ao limpar a pasta Temp: {e}")

delete_Temp_pro()