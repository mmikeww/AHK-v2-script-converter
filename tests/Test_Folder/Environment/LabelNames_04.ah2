; glabel name will cause conflict once renamed
myGui := Gui()
ogcButtonMakeMsgBox := myGui.Add("Button", , "Make MsgBox")
ogcButtonMakeMsgBox.OnEvent("Click", Init_Vars_2.Bind("Normal"))
myGui.Show()
Return

; has conflict with other label once renamed
Init_Vars_2(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("Created MsgBox")
Init_Vars_3()
Return
} ; V1toV2: Added Bracket before label

Init_Vars()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("conflicting label name 1")
Init_Vars_2()
Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

^i::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("hotkey pressed")
Init_Vars()
Return
} ; V1toV2: Added bracket before function

Init_Vars_3()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("conflicting label name 3")
return
} ; V1toV2: Added Bracket before label

Init_Vars_4:	; comment
MsgBox("conflicting label name 4")

;Init@Vars()
;{
;msgbox % msgbox conflicting name 2
;}