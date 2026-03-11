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
ExitApp()
}
