; Create the popup menu by adding some items to it.
Menu, MyMenu, Add, Item1, MenuHandler
Menu, MyMenu, Add, Item2, MenuHandler
Menu, MyMenu, Add  ; Add a separator line.

; Create another menu destined to become a submenu of the above menu.
Menu, Submenu1, Add, Item1, MenuHandler
Menu, Submenu1, Add, Item2, MenuHandler

; Create a submenu in the first menu (a right-arrow indicator). When the user selects it, the second menu is displayed.
Menu, MyMenu, Add, My Submenu, :Submenu1

Menu, MyMenu, Add  ; Add a separator line below the submenu.
Menu, MyMenu, Add, Item3, MenuHandler  ; Add another menu item beneath the submenu.
return  ; End of script's auto-execute section.

MenuHandler:
MsgBox You selected %A_ThisMenuItem% from the menu %A_ThisMenu%.
return

#z::Menu, MyMenu, Show  ; i.e. press the Win-Z hotkey to show the menu.