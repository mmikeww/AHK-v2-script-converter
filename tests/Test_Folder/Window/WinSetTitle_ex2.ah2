Run("notepad.exe")
WinWaitActive("Untitled - Notepad")
WinSetTitle("This is a new title") ; Use the window found by WinWaitActive.