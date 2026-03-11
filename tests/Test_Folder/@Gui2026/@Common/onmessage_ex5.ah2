; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
Persistent

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("Text","y25","Press any key`nOR`nLeft/Right Click")
mV2Gui["1"].Show("w100 h100")

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