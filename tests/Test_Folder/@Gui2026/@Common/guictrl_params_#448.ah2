; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","ClickMe"]] := mV2Gui["1"].Add("Button",,"Click Me")
mV2GC[["1","ClickMe"]].OnEvent("Click",MyFunction.Bind("Normal"))
mV2Gui["1"].Show()
return

MyFunction(GuiEvent:="", CtrlHwnd:="", EventInfo:="", *) {
    MsgBox("CtrlHwnd:`t" CtrlHwnd.hwnd "`nEvent:`t" GuiEvent "`nInfo:`t" EventInfo)
}