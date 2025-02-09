
def window_main(tk:object ,text:str, close=False):
    # Cria uma janela com a mensagem "RODANDO...."
    tkr = tk.Tk()
    tkr.title("App Limpeza")
    tkr.geometry("205x140")
    tkr.configure(bg="gray")
    tkr.overrideredirect(True)
    label = tk.Label(
        tkr, text=text, background="gray",fg="gold",padx=40,
        pady=40,font=("Helvetica", 16)
        )
    label.pack()
    if close:
        button = tk.Button(
            tkr, text="Fechar", command=tkr.destroy ,bg="red", 
            fg="white" ,font=("Helvetica", 12),borderwidth=2, relief="solid"
            )
        button.pack()
    else :
        tkr.after(3000, tkr.destroy)
        
    tkr.mainloop()
    

