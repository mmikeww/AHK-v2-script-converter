#Persistent

Gui, Add, Text, x15 y35, Left-click Me!
Gui, Show, w100 h100

var = WM_LBUTTONDOWN
OnMessage(0x201, var)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    MsgBox LClicked
}