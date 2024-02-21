MyGui := Gui()
MyGui.Add("Text",, "Click anywhere in this window.")
MyGui.Add("Edit", "w200")
MyGui.Show
OnMessage 0x0201, WM_LBUTTONDOWN

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
    X := lParam & 0xFFFF
    Y := lParam >> 16
    Control := ""
    thisGui := GuiFromHwnd(hwnd)
    thisGuiControl := GuiCtrlFromHwnd(hwnd)
    if thisGuiControl
    {
        thisGui := thisGuiControl.Gui
        Control := "`n(in control " . thisGuiControl.ClassNN . ")"
    }
    ToolTip "You left-clicked in Gui window '" thisGui.Title "' at client coordinates " X "x" Y "." Control
}

F5:: {
Tooltip
OnMessage(0x0201, WM_LBUTTONDOWN, 0)
}