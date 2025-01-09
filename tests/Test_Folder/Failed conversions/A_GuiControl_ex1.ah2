myGui := Gui()
ogcButtonName := myGui.Add("Button", , "Name")
ogcButtonName.OnEvent("Click", ButtonName.Bind("Normal"))
myGui.Show()
Return

ButtonName(A_GuiEvent := "", A_GuiControl := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
A_GuiControl := HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl
MsgBox(A_GuiControl)
} ; V1toV2: Added bracket in the end