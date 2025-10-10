; https://github.com/mmikeww/AHK-v2-script-converter/issues/384

OnMessage(MsgNum, ShellMessage)
ShellMessage( wParam, lParam, msg, hwnd ) {
MsgBox("add missing params and preserve whitespace")
}

OnMessage(WM_NOTIFY := 0x4E, LV_NOTIFY)
LV_NOTIFY(wParam, lParam, msg, hwnd, W, L) {
MsgBox("add missing params and preserve originals")
}