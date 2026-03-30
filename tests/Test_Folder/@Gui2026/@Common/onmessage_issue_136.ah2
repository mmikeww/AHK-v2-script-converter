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
OnMessage(0x0201, WM_LBUTTONDOWN)
return

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
  ToolTip("GUI Clicked")
}

F5::HK1_F5()
Return

GuiClose:
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
HK1_F5() { ; V1toV2: HK->Func
global
OnMessage(0x0201, WM_LBUTTONDOWN, 0)
Return
}
;##############################################
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
