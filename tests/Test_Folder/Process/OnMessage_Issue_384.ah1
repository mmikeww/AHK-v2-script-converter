; https://github.com/mmikeww/AHK-v2-script-converter/issues/384

OnMessage( MsgNum, "ShellMessage" )
ShellMessage( wParam,lParam ) {
msgbox add missing params and preserve whitespace
}

OnMessage(WM_NOTIFY := 0x4E, "LV_NOTIFY")
LV_NOTIFY(W, L) {
msgbox % "add missing params and preserve originals"
}