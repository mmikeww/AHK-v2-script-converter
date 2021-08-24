Colors := "red,green,blue"
Loop Parse, Colors, ","
{
    msgResult := MsgBox("Color number " . A_Index . " is " . A_LoopField . ".")
}