; https://github.com/mmikeww/AHK-v2-script-converter/issues/384

OnMessage(MsgNum, ShellMessage)
ShellMessage( wParam,lParam, msg, hwnd ) {
	if !(wParam ~= "^(?i:" RegExReplace(RegExReplace(Filters,"[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\h*,\h*","|") ")$"){
	}
}

OnMessage(WM_NOTIFY := 0x4E, LV_NOTIFY)
LV_NOTIFY(W, L, msg, hwnd) {
MsgBox("add missing params and preserve originals")
}