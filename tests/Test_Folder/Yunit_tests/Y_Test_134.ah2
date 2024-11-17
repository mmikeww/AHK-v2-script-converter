InputVar := "The Red Fox"
left := "LOL"
if (SubStr(left, 1, 1) = "L")
    out := SubStr(SubStr(InputVar, 1, 7), -3)
else
    out := SubStr(InputVar, 7, 3)
FileAppend(out, "*")