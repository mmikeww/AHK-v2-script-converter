myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.Add("Text", , "Click anywhere in this window.")
ogcMyEdit := myGui.Add("Edit", "w200 vMyEdit")
myGui.Show()
On()
return

^l::Off()

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
    X := lParam & 0xFFFF
    Y := lParam >> 16
    ToolTip("You left-clicked in Gui window at client coordinates x" X "y" Y)
}

GuiClose(*)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ExitApp()
Return
} ; V1toV2: Added bracket before function

Off() {
    ToolTip()
    OnMessage(0x0201, WM_LBUTTONDOWN, 0)
}

On() {
    OnMessage(0x0201, WM_LBUTTONDOWN)
}