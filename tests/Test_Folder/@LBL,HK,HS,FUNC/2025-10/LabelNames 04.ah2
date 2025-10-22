; glabel name will cause conflict once renamed
myGui := Gui()
ogcButtonMakeMsgBox := myGui.Add("Button", , "Make MsgBox")
ogcButtonMakeMsgBox.OnEvent("Click", Init_Vars_2.Bind("Normal"))
myGui.Show()
Return

; has conflict with other label once renamed
Init_Vars_2:
Init_Vars_2()
Return

Init_Vars:
Init_Vars()
Return

^i::HK1_i()
Return

Init_Vars_3:
Init_Vars_3()
return

Init_Vars_4:	; comment
Init_Vars_4()
return

;###############  V1toV2 FUNCS  ###############
Init_Vars_2(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Created MsgBox")
Init_Vars_3() ; V1toV2: Gosub
Return
}
;##############################################
Init_Vars() { ; V1toV2: Lbl->Func
global
MsgBox("conflicting label name 1")
Init_Vars_2() ; V1toV2: Gosub
Return
}
;##############################################
HK1_i() { ; V1toV2: HK->Func
global
MsgBox("hotkey pressed")
Init_Vars() ; V1toV2: Gosub
Return
}
;##############################################
Init_Vars_3() { ; V1toV2: Lbl->Func
global
MsgBox("conflicting label name 3")
return
}
;##############################################
Init_Vars_4() { ; V1toV2: Lbl->Func
global
MsgBox("conflicting label name 4")
}

;Init@Vars()
;{
;msgbox % msgbox conflicting name 2
;}