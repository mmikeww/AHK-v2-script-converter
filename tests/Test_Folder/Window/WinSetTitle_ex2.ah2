Run("notepad.exe")
ErrorLevel := WinWaitActive("Untitled - Notepad", , , , ) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
WinSetTitle("This is a new title") ; Use the window found by WinWaitActive.