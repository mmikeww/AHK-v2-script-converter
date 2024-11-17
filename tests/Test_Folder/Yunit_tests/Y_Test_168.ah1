Colors := "red,green,blue"
Loop, parse, Colors, `,
{
    MsgBox, Color number %A_Index% is %A_LoopField%.
}