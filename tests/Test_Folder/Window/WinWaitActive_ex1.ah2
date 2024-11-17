Run("notepad.exe")
ErrorLevel := !WinWaitActive("Untitled - Notepad", , 2)
if ErrorLevel
{
    MsgBox("WinWait timed out.")
    return
}
else
    WinMinimize() ; Use the window found by WinWaitActive.