; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",GuiClose)
}
mV2Gui["1"].Add("Text",,"Click anywhere in this window.")
mV2GC[["1","MyEdit"]] := mV2Gui["1"].Add("Edit","w200 vMyEdit")
mV2Gui["1"].Show()
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