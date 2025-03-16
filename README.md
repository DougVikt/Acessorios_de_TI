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
    - [Sobre](#sobe--2)
    - [Uso](#uso--2)
    - [Componentes](#componentes-)

<br>

## Limpeza_geral 

### Sobre :
Um script em lote (bat) simples com a função de remover arquivos desnecessários e verificar a integridade dos arquivos do sistema. Ele inclui os seguintes comandos:
- Limpeza de arquivos temporários;
- Execução da ferramenta de limpeza de disco;
- Verificação de arquivos corrompidos no sistema;
- Verificação de arquivos gerais.

### Uso :
O uso é muito simples: ao executar o script, será exibido um menu personalizado no console, onde o usuário poderá escolher entre as quatro opções de funcionalidades. Todo o processo ocorre diretamente no prompt de comando, sem a necessidade de abrir outras janelas. Ao final de cada comando executado, uma mensagem de confirmação de conclusão será exibida, e o script retornará ao menu para que o usuário possa realizar uma nova escolha.

<br><br>

## Up_apps

### Sobre :
Um script em lote (bat) dedicado exclusivamente à atualização das aplicações do computador. Ele é capaz de atualizar tanto os softwares instalados quanto os aplicativos da Microsoft Store, desde que as aplicações possuam um caminho de atualização definido em seu manifesto.

### Uso :
Quando o script é executado, uma janela do prompt de comando será aberta, e o processo será realizado automaticamente, sem a necessidade de interação do usuário. Para atualizar todos os programas disponíveis, é necessário executar o script como administrador. Caso o script não funcione, pode ser porque o computador não possui o 'winget' instalado. Nesses casos, será necessário baixar manualmente o aplicativo 'App Installer' diretamente da Microsoft.
<br><br>

## TiClean

### Sobre :
Um programa desenvolvido em Python para realizar a limpeza de arquivos temporários e de disco de forma automatizada. O programa foi projetado de modo que sua execução seja visível ao usuário, permitindo acompanhar o progresso das operações em tempo real e garantindo a confiança de que o processo está realmente em andamento.

### Componentes :
1. **main.py :**
Script principal de execução responsável por integrar e controlar todas as funções necessárias para o pleno funcionamento da aplicação. Ele serve como o núcleo central, coordenando os processos e garantindo que cada funcionalidade seja executada corretamente e de maneira eficiente.
2. **window.py :**
Script contendo a função da janela  