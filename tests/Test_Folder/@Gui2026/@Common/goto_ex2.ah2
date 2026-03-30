#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","MakeMsgBox"]] := mV2Gui[""].Add("Button",,"Make MsgBox")
mV2GC[["","MakeMsgBox"]].OnEvent("Click",InitVars.Bind("Normal"))
mV2Gui[""].Show()
Return

InitVars:
InitVars()
Return

^l::HK1_l()
Return

;###############  V1toV2 FUNCS  ###############
InitVars(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Created MsgBox")
Return
}
;##############################################
HK1_l() { ; V1toV2: HK->Func
global
InitVars() ; V1toV2: Goto->FuncCall
Return
}