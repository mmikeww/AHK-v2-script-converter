Run("notepad.exe")
ErrorLevel := WinWait("Untitled - Notepad", , 3) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
if ErrorLevel
{
    MsgBox("WinWait timed out.")
    return
}
else
    WinMinimize() ; Use the window found by WinWait.