Gui, Add, Text,, Click anywhere in this window.
Gui, Add, Edit, w200 vMyEdit
Gui, Show
OnMessage(0x0201, "WM_LBUTTONDOWN")
return

WM_LBUTTONDOWN(wParam, lParam)
{
  ToolTip, GUI Clicked
}

F5::
OnMessage(0x0201, "")
Return

GuiClose:
ExitApp
