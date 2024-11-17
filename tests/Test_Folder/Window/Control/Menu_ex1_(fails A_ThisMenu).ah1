#Persistent  ; Keep the script running until the user exits it.
Menu, Tray, Add  ; Creates a separator line.
Menu, Tray, Add, Item1, MenuHandler  ; Creates a new menu item.
return

MenuHandler:
MsgBox You selected %A_ThisMenuItem% from menu %A_ThisMenu%.
return