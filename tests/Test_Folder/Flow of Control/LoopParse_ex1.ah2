Colors := "red,green,blue"
Loop Parse, Colors, ","
{
    MsgBox("Color number " A_Index " is " A_LoopField ".")
}