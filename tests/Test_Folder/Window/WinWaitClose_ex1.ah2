Run("notepad.exe")
WinWait("Untitled - Notepad")
ErrorLevel := WinWaitClose(, , , , ) , ErrorLevel := ErrorLevel = 0 ? 1 : 0 ; Use the window found by WinWait.
MsgBox("Notepad is now closed.")