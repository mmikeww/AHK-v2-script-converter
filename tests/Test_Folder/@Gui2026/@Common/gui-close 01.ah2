; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
; fix for func params not being updated when label text-case does not match AHK map key

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",guiclose)
}
mV2Gui["1"].SetFont("s12")
var:="test"
mV2GC[["1","txt"]] := mV2Gui["1"].add("text","vtxt center",var)
mV2Gui["1"].show()
return

guiclose:
guiclose()
ExitApp()
return

;###############  V1toV2 FUNCS  ###############
guiclose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}