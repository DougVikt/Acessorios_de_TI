
def window_main(tk:object ,text:str,version:str ,close=False):
    # Cria uma janela com a mensagem 
    tkr = tk.Tk()
    tkr.title("App Limpeza")
    tkr.geometry("210x100")
    tkr.configure(bg="gray")
    tkr.overrideredirect(True)
    label_version = tk.Label(
        tkr,text=f"V {version}",background='gray'
    )
    label_version.pack()
    label = tk.Label( 
        tkr, text=text, background="gray",fg="gold",padx=30,
        pady=30,font=("Helvetica", 16)
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
    

