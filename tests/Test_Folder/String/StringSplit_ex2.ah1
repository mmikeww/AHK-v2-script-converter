Colors := "red,green,blue"
StringSplit, ColorArray, Colors, `,
Loop, %ColorArray0%
{
    this_color := ColorArray%A_Index%
    MsgBox, Color number %A_Index% is %this_color%.
}