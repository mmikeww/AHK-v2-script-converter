#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
Persistent

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text","x15 y35","Left/Right Click")
mV2Gui[""].Show("w100 h100")

OnMessage(0x201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(a, b, msg, hwnd) {
    ToolTip(a "`n" b)
}

var := "value"
OnMessage(0x204, WM_RBUTTONDOWN.Bind(var))
WM_RBUTTONDOWN(bindedParam, wParam, lParam, msg, hwnd) {
    ToolTip(bindedParam "`n" wParam "`n" lParam)
}