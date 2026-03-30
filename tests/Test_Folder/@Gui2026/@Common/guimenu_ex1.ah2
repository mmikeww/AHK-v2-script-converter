#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
MyMenu := MenuBar()
MyMenu.Add("&File", mnuFile)
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].MenuBar := MyMenu
mV2Gui[""].Show("w200 h200")

return
mnuFile:
mnuFile()
return

;###############  V1toV2 FUNCS  ###############
mnuFile(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Yes? Why are you interrupting my nap?")
}