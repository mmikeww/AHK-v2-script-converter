InputVar := "The Red Fox"
out := SubStr(SubStr(InputVar, 1, 7), StrLen(InputVar) >= 7 ? -3 : StrLen(InputVar)-7)
FileAppend(out, "*")