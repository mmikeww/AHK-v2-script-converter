Run, notepad.exe
WinWait, Untitled - Notepad,, 3
if ErrorLevel
{
    MsgBox, WinWait timed out.
    return
}
else
    WinMinimize ; Use the window found by WinWait.