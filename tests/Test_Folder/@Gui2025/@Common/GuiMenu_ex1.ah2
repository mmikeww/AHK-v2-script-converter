#Warn Unreachable, Off
MyMenu := MenuBar()
MyMenu.Add("&File", mnuFile)
myGui := Gui()
myGui.MenuBar := MyMenu
myGui.Show("w200 h200")

return
mnuFile:
mnuFile()
return

;###############  V1toV2 FUNCS  ###############
mnuFile(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Yes? Why are you interrupting my nap?")
}