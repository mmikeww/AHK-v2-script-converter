myGui := Gui()
ogcRadio_Type := myGui.Add("Radio", "v_Type", "Option 1")
myGui.Add("Radio", , "Option 2")
ogcButtonCheckResponse := myGui.Add("Button", , "Check Response")
ogcButtonCheckResponse.OnEvent("Click", CheckResponse.Bind("Normal"))
myGui.Show()
Return

CheckResponse(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
_Type := ogcRadio_Type.Value
If (_Type = 1) {
  MsgBox("You Selected Option 1")
} else {
  MsgBox("You Selected Option 2")
}
} ; V1toV2: Added bracket in the end