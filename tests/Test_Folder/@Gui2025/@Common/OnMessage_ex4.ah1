Gui, Add, Text,, Click anywhere in this window.
Gui, Add, Edit, w200 vMyEdit
Gui, Show
On()
return

^l::Off()

WM_LBUTTONDOWN(wParam, lParam)
{
    X := lParam & 0xFFFF
    Y := lParam >> 16
    ToolTip You left-clicked in Gui window at client coordinates x%X%y%Y%
}

GuiClose:
ExitApp
Return

Off() {
    ToolTip
    OnMessage(0x0201, "")
}

On() {
    OnMessage(0x0201, "WM_LBUTTONDOWN")
}