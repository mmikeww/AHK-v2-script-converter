#Warn Unreachable, Off
myGui := Gui()
ogcButtonButton1 := myGui.Add("Button", , "Button 1")
ogcButtonButton1.OnEvent("Click", b1.Bind("Normal"))
ogcEdite1 := myGui.Add("Edit", "ve1", "Some Text")
myGui.Show()
Return

b1:
b1()
return

;###############  V1toV2 FUNCS  ###############
b1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
Var := "Focus" ; This fix works with focus, others won't
ogcEdite1.%var%() ; V1toV2: SubCommand passed as variable, check variable contents and docs
}
