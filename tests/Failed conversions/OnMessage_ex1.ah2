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

F5::
{ ; V1toV2: Added bracket
OnMessage(0x0201, WM_LBUTTONDOWN, 0)
Return
} ; Added bracket before function

GuiClose(*)
{ ; V1toV2: Added bracket
ExitApp()


} ; Added bracket in the end