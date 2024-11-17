WinGet, ActiveControlList, ControlList, A
Loop, Parse, ActiveControlList, `n
{
    MsgBox, 4,, Control #%A_Index% is "%A_LoopField%". Continue?
    IfMsgBox, No
        break
}