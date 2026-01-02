#Warn Unreachable, Off
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.Add("Text", , "Click anywhere in this window.")
ogcMyEdit := myGui.Add("Edit", "w200 vMyEdit")
myGui.Show()
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
