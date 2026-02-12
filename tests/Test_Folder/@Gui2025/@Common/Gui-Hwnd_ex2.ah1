Gui, Add, Text,vTextC, HWND Test
Gui, Add, Edit, vFirstName hwndtest
Gui, Add, Button, gClicked, Submit
Gui, Show
Return

Clicked:
MsgBox % test
Return