myGui := Gui()
ogcButtonOK := myGui.Add("Button", , "OK")
ogcButtonOK.OnEvent("Click", ButtonOK.Bind("Normal"))
myGui.Show()
Return

ButtonOK(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
myGui.Hide()
} ; V1toV2: Added bracket in the end