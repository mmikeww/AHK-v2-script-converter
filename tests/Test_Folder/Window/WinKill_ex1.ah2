if WinExist("Untitled - Notepad")
    WinKill() ; Use the window found by WinExist.
else
    WinKill("Calculator")