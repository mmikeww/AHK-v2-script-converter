; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
Persistent

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("Text","x15 y35","Left-click Me!")
mV2Gui["1"].Show("w100 h100")

var := "WM_LBUTTONDOWN"
OnMessage(0x201, %var%)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    MsgBox("LClicked")
}