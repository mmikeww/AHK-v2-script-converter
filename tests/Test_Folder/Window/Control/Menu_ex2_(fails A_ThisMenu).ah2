; Create the popup menu by adding some items to it.
MyMenu := Menu()
MyMenu.Add("Item1", MenuHandler)
MyMenu.Add("Item2", MenuHandler)
MyMenu.Add()  ; Add a separator line.

; Create another menu destined to become a submenu of the above menu.
Submenu1 := Menu()
Submenu1.Add("Item1", MenuHandler)
Submenu1.Add("Item2", MenuHandler)

; Create a submenu in the first menu (a right-arrow indicator). When the user selects it, the second menu is displayed.
MyMenu.Add("My Submenu", Submenu1)

MyMenu.Add()  ; Add a separator line below the submenu.
MyMenu.Add("Item3", MenuHandler)  ; Add another menu item beneath the submenu.
return  ; End of script's auto-execute section.

MenuHandler(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("You selected " A_ThisMenuItem " from the menu " A_ThisMenu ".")
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

#z::MyMenu.Show()  ; i.e. press the Win-Z hotkey to show the menu.