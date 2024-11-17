In1 := "The Red Fox"
Out1 := SubStr(SubStr(In1, 1, 11), StrLen(In1) >= 11 ? -3 : StrLen(In1)-11)
Out2 := SubStr(SubStr(In1, 1, 14), StrLen(In1) >= 14 ? -6 : StrLen(In1)-14)
MsgBox(Out1 "`n" Out2)