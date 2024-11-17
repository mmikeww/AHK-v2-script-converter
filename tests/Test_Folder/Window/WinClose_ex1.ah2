if WinExist("Untitled - Notepad")
    WinClose() ; Use the window found by WinExist.
else
    WinClose("Calculator")