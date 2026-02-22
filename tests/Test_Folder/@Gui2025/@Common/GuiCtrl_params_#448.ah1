Gui, Add, Button, gMyFunction, Click Me
Gui, Show
return

MyFunction(CtrlHwnd, GuiEvent, EventInfo) {
    MsgBox % "CtrlHwnd:`t" CtrlHwnd "`nEvent:`t" GuiEvent "`nInfo:`t" EventInfo
}