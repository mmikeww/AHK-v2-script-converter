if WinExist("Untitled - Notepad")
    WinActivate() ; Use the window found by WinExist.
else
    WinActivate("Calculator")