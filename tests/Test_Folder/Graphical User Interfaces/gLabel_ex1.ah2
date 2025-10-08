myGui := Gui()
ogcButtonThing := myGui.Add("Button", "vThing", "Thing")
ogcButtonThing.OnEvent("Click", Thing.Bind("Normal"))
myGui.Show()
return

Thing:
Thing()
return

;###############  V1toV2 FUNCS  ###############
Thing(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Thing")
return
}