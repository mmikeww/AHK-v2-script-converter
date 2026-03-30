#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","ClickMe"]] := mV2Gui[""].Add("Button",,"Click Me")
mV2GC[["","ClickMe"]].OnEvent("Click",MyFunction.Bind("Normal"))
mV2Gui[""].Show()
return

MyFunction(GuiEvent:="", CtrlHwnd:="", EventInfo:="", *) {
    (IsSet(CtrlHwnd)) && SetDefaultGui(CtrlHwnd)
    MsgBox("CtrlHwnd:`t" CtrlHwnd.hwnd "`nEvent:`t" GuiEvent "`nInfo:`t" EventInfo)
}