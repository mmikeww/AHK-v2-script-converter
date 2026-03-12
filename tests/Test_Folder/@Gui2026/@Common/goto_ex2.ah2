; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","MakeMsgBox"]] := mV2Gui["1"].Add("Button",,"Make MsgBox")
mV2GC[["1","MakeMsgBox"]].OnEvent("Click",InitVars.Bind("Normal"))
mV2Gui["1"].Show()
Return

InitVars:
InitVars()
Return

^l::HK1_l()
Return

;###############  V1toV2 FUNCS  ###############
InitVars(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Created MsgBox")
Return
}
;##############################################
HK1_l() { ; V1toV2: HK->Func
global
InitVars() ; V1toV2: Goto->FuncCall
Return
}