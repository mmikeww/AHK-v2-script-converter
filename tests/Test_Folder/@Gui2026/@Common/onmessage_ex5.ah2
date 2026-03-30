#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
Persistent

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text","y25","Press any key`nOR`nLeft/Right Click")
mV2Gui[""].Show("w100 h100")

OnMessage(0x201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    MsgBox("LClicked")
}


OnMessage(0x204, WM_RBUTTONDOWN.Bind("with bind"))
WM_RBUTTONDOWN(test, wParam, lParam, msg, hwnd) {
    MsgBox("RClicked " test)
}


funcName := "WM_KEYDOWN"
OnMessage(0x100, %funcName%)
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    MsgBox("Key Pressed")
}