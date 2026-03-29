#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
Persistent

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text","x15 y35","Left-click Me!")
mV2Gui[""].Show("w100 h100")

var := "WM_LBUTTONDOWN"
OnMessage(0x201, %var%)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    MsgBox("LClicked")
}