Persistent  ; Keep the script running until the user exits it.
Tray:= A_TrayMenu
Tray.Add()  ; Creates a separator line.
Tray.Add("Item1", MenuHandler)  ; Creates a new menu item.
return

MenuHandler(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("You selected " A_ThisMenuItem " from menu " A_ThisMenu ".")
return
} ; V1toV2: Added bracket in the end