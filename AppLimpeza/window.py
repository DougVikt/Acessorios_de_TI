
def window_main(tk:object ,text:str, close=False):
    # Cria uma janela com a mensagem 
    tkr = tk.Tk()
    tkr.title("App Limpeza")
    tkr.geometry("210x100")
    tkr.configure(bg="gray")
    tkr.overrideredirect(True)
    label = tk.Label( 
        tkr, text=text, background="gray",fg="gold",padx=40,
        pady=40,font=("Helvetica", 16)
    ) # janela de inicio
    label.pack()
    if close:
        tkr.geometry("210x150")
        button = tk.Button( 
            tkr, text="Fechar", command=tkr.destroy ,bg="red", 
            fg="black" ,font=("Helvetica", 12),borderwidth=2, relief="ridge",
            padx=20
        ) # botão para fechar 
        button.pack()
    else :
        tkr.after(3000, tkr.destroy)
        
    tkr.mainloop()
    

