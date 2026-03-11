; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
MyMenu := MenuBar()
MyMenu.Add("&File", mnuFile)
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].MenuBar := MyMenu
mV2Gui["1"].Show("w200 h200")

return
mnuFile:
mnuFile()
return

;###############  V1toV2 FUNCS  ###############
mnuFile(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Yes? Why are you interrupting my nap?")
}