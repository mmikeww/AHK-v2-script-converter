WinActivate("Untitled - Notepad")
OutputVar := ControlGetClassNN(ControlGetFocus("Untitled - Notepad"))
MsgBox("Control with focus = " OutputVar)