myGui := Gui()
ogcButtonThing := myGui.Add("Button", "vThing", "Thing")
ogcButtonThing.OnEvent("Click", Thing.Bind("Normal"))
myGui.Show()
return

Thing(A_GuiEvent := "", A_GuiControl := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("Thing")
return
} ; V1toV2: Added bracket in the end