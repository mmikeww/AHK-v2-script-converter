#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
^l::HK1_l()
return

GuiClose:
GuiClose()
return

;###############  V1toV2 FUNCS  ###############
HK1_l() { ; V1toV2: HK->Func
global
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
}
mV2Gui[""].Show("w100 h100")
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Gui Closed")
}