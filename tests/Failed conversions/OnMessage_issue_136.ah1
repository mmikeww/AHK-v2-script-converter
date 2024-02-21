Gui, Add, Text,, Click anywhere in this window.
Gui, Add, Edit, w200 vMyEdit
Gui, Show
OnMessage(0x0201, "WM_LBUTTONDOWN")
return

WM_LBUTTONDOWN(wParam, lParam)
{
    X := lParam & 0xFFFF
    Y := lParam >> 16
    if A_GuiControl
        Ctrl := "`n(in control " . A_GuiControl . ")"
    ToolTip You left-clicked in Gui window #%A_Gui% at client coordinates %X%x%Y%.%Ctrl%
}

F5::
Tooltip
OnMessage(0x0201, "")
Return

GuiClose:
ExitApp