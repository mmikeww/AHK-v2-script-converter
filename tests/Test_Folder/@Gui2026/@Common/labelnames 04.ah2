#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
; glabel name will cause conflict once renamed
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","MakeMsgBox"]] := mV2Gui[""].Add("Button",,"Make MsgBox")
mV2GC[["","MakeMsgBox"]].OnEvent("Click",Init_Vars_2.Bind("Normal"))
mV2Gui[""].Show()
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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Created MsgBox")
Init_Vars_3() ; V1toV2: Gosub
Return
}
;##############################################
Init_Vars() { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("conflicting label name 3")
return
}
;##############################################
Init_Vars_4() { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("conflicting label name 4")
}

;Init@Vars()
;{
;msgbox % msgbox conflicting name 2
;}