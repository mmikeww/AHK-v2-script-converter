#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
; fix for func params not being updated when label text-case does not match AHK map key

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",guiclose)
}
mV2Gui[""].SetFont("s12")
var:="test"
mV2GC[["","txt"]] := mV2Gui[""].add("text","vtxt center",var)
mV2Gui[""].show()
return

guiclose:
guiclose()
ExitApp()
return

;###############  V1toV2 FUNCS  ###############
guiclose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}