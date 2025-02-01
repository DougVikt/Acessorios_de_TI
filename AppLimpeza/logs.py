import os
from datetime import datetime

def register_logs(content_log:str):  
  
    try:
        # pega o caminho absoluto do arquivo
        file_absotute = os.path.dirname(os.path.abspath(__file__))
        # caminho do arquivo de log
        file_log = os.path.join(file_absotute, 'logs.txt')
        # pega a data e hora atual
        date_create = datetime.now().strftime('%d/%m/%Y %H:%M:%S')
       
        # verifica se o arquivo de log existe se não cria
        if os.path.exists(file_log):
            # cria o arquivo de log
            with open('logs.txt', 'w') as file:
                # escreve a data e hora de criação do arquivo
                file.write(f"file creation date :{date_create}")
        elif not os.path.exists(file_log):
            print("indo")
            # abre o arquivo de log e escreve 
            with open('logs.txt', 'a') as file:
                # escreve o conteúdo do log
                file.write(f"\nLOG-{date_create}: {content_log}")
    except Exception as e:
        print(f'Error to write log : {e}')