Run("notepad.exe")
WinWait("Untitled - Notepad")
WinWaitClose() ; Use the window found by WinWait.
MsgBox("Notepad is now closed.")