myGui := Gui()
ogcRadioType := myGui.Add("Radio", "vType", "Option 1")
myGui.Add("Radio", , "Option 2")
ogcButtonCheckResponse := myGui.Add("Button", , "Check Response")
ogcButtonCheckResponse.OnEvent("Click", CheckResponse.Bind("Normal"))
myGui.Show()
Return

CheckResponse(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
Type := ogcRadioType.Value
If (Type = 1) {
  MsgBox("You Selected Option 1")
} else {
  MsgBox("You Selected Option 2")
}

} ; Added bracket in the end