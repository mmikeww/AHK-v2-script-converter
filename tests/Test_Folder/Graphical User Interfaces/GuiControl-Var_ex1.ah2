myGui := Gui()
ogcButtonButton1 := myGui.Add("Button", , "Button 1")
ogcButtonButton1.OnEvent("Click", b1.Bind("Normal"))
ogcEdite1 := myGui.Add("Edit", "ve1", "Some Text")
myGui.Show()
Return

b1(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Var := "Focus" ; This fix works with focus, others won't
ogcEdite1.%var%() ; V1toV2: SubCommand passed as variable, check variable contents and docs
} ; V1toV2: Added bracket in the end
