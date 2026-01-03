#Warn Unreachable, Off
myGui := Gui()
ogcButtonName := myGui.Add("Button", "w100", "Name")
ogcButtonName.OnEvent("Click", ButtonName.Bind("Normal"))
ogcEditTestnTest := myGui.Add("Edit", "R2 w100", "Test`nTest")
ogcEditTestnTest.OnEvent("Change", ButtonName.Bind("Normal"))
myGui.Show("w120")
Return

ButtonName:
ButtonName()
return

;###############  V1toV2 FUNCS  ###############
ButtonName(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
A_GuiControl := HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl
MsgBox("A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl)
}