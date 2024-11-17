if WinActive("Untitled - Notepad")
{
    WinMaximize() ; Use the window found by IfWinActive.
    Send("Some text.{Enter}")
    return
}