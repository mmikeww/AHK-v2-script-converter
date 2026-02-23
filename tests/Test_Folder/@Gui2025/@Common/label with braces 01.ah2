#Warn Unreachable, Off
myGui := Gui()
ogcButton1 := myGui.Add("Button", "vButton1", "Button1")
ogcButton1.OnEvent("Click", ButtonPress.Bind("Normal"))
ogcButton2 := myGui.Add("Button", "vButton2", "Button2")
ogcButton2.OnEvent("Click", ButtonPress.Bind("Normal"))
ogcButton3 := myGui.Add("Button", "vButton3", "Button3")
ogcButton3.OnEvent("Click", ButtonPress.Bind("Normal"))
ogcButton4 := myGui.Add("Button", "vButton4", "Button4")
ogcButton4.OnEvent("Click", ButtonPress.Bind("Normal"))
ogcButton5 := myGui.Add("Button", "vButton5", "Button5")
ogcButton5.OnEvent("Click", ButtonPress.Bind("Normal"))
myGui.Title := "Test"
myGui.Show()
Return

ButtonPress:
ButtonPress()
Return

;###############  V1toV2 FUNCS  ###############
ButtonPress(A_GuiEvent:="", A_GuiControl:="", Info:="", *)
{ ; V1toV2: Lbl->Func
;global
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("You pressed:" A_GuiControl)
Return
}