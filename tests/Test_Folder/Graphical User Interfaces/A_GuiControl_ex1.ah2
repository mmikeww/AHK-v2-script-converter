myGui := Gui()
ogcButtonName := myGui.Add("Button", "w100", "Name")
ogcButtonName.OnEvent("Click", ButtonName.Bind("Normal"))
ogcEditTestnTest := myGui.Add("Edit", "R2 w100", "Test`nTest")
ogcEditTestnTest.OnEvent("Change", ButtonName.Bind("Normal"))
myGui.Show("w120")
Return

ButtonName(A_GuiEvent := "", A_GuiControl := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
A_GuiControl := HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl
MsgBox("A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl)
} ; V1toV2: Added bracket in the end