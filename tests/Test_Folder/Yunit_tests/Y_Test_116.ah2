Haystack := "abcdefabcdef"
Needle := "cde"
pos := InStr(Haystack, Needle,, (4)+1) - 1
if (pos >= 0)
    MsgBox("The string was found at position " pos ".")