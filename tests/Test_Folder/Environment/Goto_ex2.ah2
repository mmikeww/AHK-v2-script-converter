#Warn Unreachable, Off
myGui := Gui()
ogcButtonMakeMsgBox := myGui.Add("Button", , "Make MsgBox")
ogcButtonMakeMsgBox.OnEvent("Click", InitVars.Bind("Normal"))
myGui.Show()
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