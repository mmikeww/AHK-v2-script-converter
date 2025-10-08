myGui := Gui()
ogcButtonOK := myGui.Add("Button", , "OK")
ogcButtonOK.OnEvent("Click", ButtonOK.Bind("Normal"))
myGui.Show()
Return

ButtonOK:
ButtonOK()
return

;###############  V1toV2 FUNCS  ###############
ButtonOK(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
myGui.Hide()
}