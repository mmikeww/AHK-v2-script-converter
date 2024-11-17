myGui := Gui()
ogcButtonMakeMsgBox := myGui.Add("Button", , "Make MsgBox")
ogcButtonMakeMsgBox.OnEvent("Click", InitVars.Bind("Normal"))
myGui.Show()
Return

InitVars(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("Created MsgBox")
Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

^l::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
InitVars()
Return
} ; V1toV2: Added bracket in the end