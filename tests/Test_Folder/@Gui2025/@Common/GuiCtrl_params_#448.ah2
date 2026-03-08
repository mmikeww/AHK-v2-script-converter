myGui := Gui()
ogcButtonClickMe := myGui.Add("Button", , "Click Me")
ogcButtonClickMe.OnEvent("Click", MyFunction.Bind("Normal"))
myGui.Show()
return

MyFunction(GuiEvent:="", CtrlHwnd:="", EventInfo:="", *) {
    MsgBox("CtrlHwnd:`t" CtrlHwnd.hwnd "`nEvent:`t" GuiEvent "`nInfo:`t" EventInfo)
}