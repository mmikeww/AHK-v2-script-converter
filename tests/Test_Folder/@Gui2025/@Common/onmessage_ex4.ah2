#Warn Unreachable, Off
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

GuiClose:
GuiClose()
ExitApp()
Return

Off() {
    ToolTip()
    OnMessage(0x0201, WM_LBUTTONDOWN, 0)
}

On() {
    OnMessage(0x0201, WM_LBUTTONDOWN)
}

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}