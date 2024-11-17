if WinExist("Untitled - Notepad")
{
    WinGetPos, Xpos, Ypos ; Use the window found by WinExist.
    MsgBox, Notepad is at %Xpos%`,%Ypos%
}