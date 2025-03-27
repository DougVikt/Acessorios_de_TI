# Acessorios de TI
Alguns scripts em batch e programas simples podem ser utilizados para otimizar o trabalho de suporte técnico, permitindo que os técnicos executem procedimentos diários de forma mais ágil e eficiente 

## Índice

- Limpeza_geral
    - [Sobre](#sobre-)
    - [Uso](#uso-)
- Up_apps
    - [Sobre](#sobre--1)
    - [Uso](#uso--1)
- TiClean
    - [Sobre](#sobre--2)
    - [Componentes](#componentes-)
    - [Uso](#uso--2)
<br>

## `Limpeza_geral` 

### *Sobre* :

Um script em lote (bat) simples com a função de remover arquivos desnecessários e verificar a integridade dos arquivos do sistema. Ele inclui os seguintes comandos:
- Limpeza de arquivos temporários;
- Execução da ferramenta de limpeza de disco;
- Verificação de arquivos corrompidos no sistema;
- Verificação de arquivos gerais.

### *Uso* :

O uso é muito simples: ao executar o script, será exibido um menu personalizado no console, onde o usuário poderá escolher entre as quatro opções de funcionalidades. Todo o processo ocorre diretamente no prompt de comando, sem a necessidade de abrir outras janelas. Ao final de cada comando executado, uma mensagem de confirmação de conclusão será exibida, e o script retornará ao menu para que o usuário possa realizar uma nova escolha.

<br><br>

## `Up_apps`

### *Sobre* :

Um script em lote (bat) dedicado exclusivamente à atualização das aplicações do computador. Ele é capaz de atualizar tanto os softwares instalados quanto os aplicativos da Microsoft Store, desde que as aplicações possuam um caminho de atualização definido em seu manifesto.

### *Uso* :

Quando o script é executado, uma janela do prompt de comando será aberta, e o processo será realizado automaticamente, sem a necessidade de interação do usuário. Para atualizar todos os programas disponíveis, é necessário executar o script como administrador. Caso o script não funcione, pode ser porque o computador não possui o 'winget' instalado. Nesses casos, será necessário baixar manualmente o aplicativo 'App Installer' diretamente da Microsoft.
<br><br>

## `TiClean`

### *Sobre* :

Um programa desenvolvido em Python para realizar a limpeza de arquivos temporários e de disco de forma automatizada. O programa foi projetado de modo que sua execução seja visível ao usuário, permitindo acompanhar o progresso das operações em tempo real e garantindo a confiança de que o processo está realmente em andamento.

### *Componentes* :

1. **main.py :**
Script principal de execução responsável por integrar e controlar todas as funções necessárias para o pleno funcionamento da aplicação. Ele serve como o núcleo central, coordenando os processos e garantindo que cada funcionalidade seja executada corretamente e de maneira eficiente.

2. **window.py :**
Script utilizando a biblioteca tkinter para criar uma janela simples. O foco está em exibir mensagens que indicam o início e o término da execução do programa, sem a inclusão de funcionalidades avançadas.
3. **delete_temp.py :**
Script que abre uma janela do explorador de arquivos no diretório dos arquivos temporários do usuário. Sua funcionalidade inclui excluir todos os arquivos possíveis no local e, ao final, fechar automaticamente a janela aberta.
4. **disk_clear.py :**
Script que abre o Limpador de Disco do sistema, incluindo comandos para minimizar e maximizar sua própria janela, garantindo que permaneça em primeiro plano. Utiliza a biblioteca pyautogui para automação via teclado, permitindo a seleção das opções desejadas e a confirmação com um clique no botão 'OK'.
5. **logs.py :** 
Script para identificar e registrar erros de execução do programa, além de monitorar e documentar em um arquivo de texto (.txt) todos os arquivos excluídos da pasta "Temp".

### Uso :
Faça o download do arquivo compactado [TiClean.rar](https://github.com/DougVikt/Acessorios_de_TI/tree/main/AppLimpeza/exe/TiClean.rar). Após extraí-lo, você encontrará o executável e instruções mais detalhadas de instalação e uso. Conforme mencionado na seção "Sobre", o programa é totalmente automatizado e requer apenas um clique inicial para começar a funcionar.

