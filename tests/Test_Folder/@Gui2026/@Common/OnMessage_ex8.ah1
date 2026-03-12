#Persistent

Gui, Add, Text, x15 y35, Left/Right Click
Gui, Show, w100 h100

OnMessage(0x201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN(a, b) {
    Tooltip % a "`n" b
}

var := "value"
OnMessage(0x204, Func("WM_RBUTTONDOWN").Bind(var))
WM_RBUTTONDOWN(bindedParam, wParam, lParam) {
    Tooltip % bindedParam "`n" wParam "`n" lParam
}