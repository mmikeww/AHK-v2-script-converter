CenterWindow("ahk_class Notepad")

CenterWindow(WinTitle)
{
    WinGetPos(, , &Width, &Height, WinTitle)
    WinMove((A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2), , , WinTitle)
}