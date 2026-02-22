myGui := Gui()
ogcButtonClickMe := myGui.Add("Button", , "Click Me")
ogcButtonClickMe.OnEvent("Click", MyFunction.Bind("Normal"))
myGui.Show()
return

MyFunction(GuiEvent:="", A_GuiControl:="", EventInfo:="", *) {
    MsgBox("CtrlHwnd:`t" A_GuiControl.hwnd "`nEvent:`t" GuiEvent "`nInfo:`t" EventInfo)
}