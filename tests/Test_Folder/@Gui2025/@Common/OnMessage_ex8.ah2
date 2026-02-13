Persistent

myGui := Gui()
myGui.Add("Text", "x15 y35", "Left/Right Click")
myGui.Show("w100 h100")

OnMessage(0x201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(a, b, msg, hwnd) {
    ToolTip(a "`n" b)
}

var := "value"
OnMessage(0x204, WM_RBUTTONDOWN.Bind(var))
WM_RBUTTONDOWN(bindedParam, wParam, lParam, msg, hwnd) {
    ToolTip(bindedParam "`n" wParam "`n" lParam)
}