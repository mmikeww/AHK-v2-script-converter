Haystack := "abcdefabcdef"
Needle := "cde"
var := 1
pos := InStr(Haystack, Needle,, (var+2)+1) - 1
if (pos >= 0)
    MsgBox("The string was found at position " pos ".")