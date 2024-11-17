Colors := "red,green,blue"
ColorArray := StrSplit(Colors,",")
Loop ColorArray.Length
{
    this_color := ColorArray[A_Index]
    MsgBox("Color number " A_Index " is " this_color ".")
}