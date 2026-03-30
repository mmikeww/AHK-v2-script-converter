#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
}
mV2Gui[""].Add("Text",,"Click anywhere in this window.")
mV2GC[["","MyEdit"]] := mV2Gui[""].Add("Edit","w200 vMyEdit")
mV2Gui[""].Show()
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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    MyEdit := ""
}