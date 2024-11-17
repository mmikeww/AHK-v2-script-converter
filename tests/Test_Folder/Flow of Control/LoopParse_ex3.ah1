Loop, parse, clipboard, `n, `r
{
    MsgBox, 4, , File number %A_Index% is %A_LoopField%.`n`nContinue?
    IfMsgBox, No, break
}