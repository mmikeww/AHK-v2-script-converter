#Persistent

Gui, Show, w100 h100

OnMessage(0x201, Func("WM_LBUTTONDOWN"))
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    MsgBox LClicked
}


OnMessage(0x204, Func("WM_RBUTTONDOWN").Bind("with bind"))
WM_RBUTTONDOWN(test, wParam, lParam, msg, hwnd) {
    MsgBox RClicked %test%
}


funcName := "WM_KEYDOWN"
OnMessage(0x100, Func(funcName))
WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    MsgBox Key Pressed
}