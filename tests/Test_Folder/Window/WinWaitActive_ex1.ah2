Run("notepad.exe")
ErrorLevel := WinWaitActive("Untitled - Notepad", , 2) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
if ErrorLevel
{
    MsgBox("WinWait timed out.")
    return
}
else
    WinMinimize() ; Use the window found by WinWaitActive.