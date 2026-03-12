; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
^l::HK1_l()
return

GuiClose:
GuiClose()
return

;###############  V1toV2 FUNCS  ###############
HK1_l() { ; V1toV2: HK->Func
global
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",GuiClose)
}
mV2Gui["1"].Show("w100 h100")
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("Gui Closed")
}