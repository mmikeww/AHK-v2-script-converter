;REMOVED StringCaseSense, on
Haystack := "abcdefabcDEF"
Needle := "DEF"
pos := InStr(Haystack, Needle) - 1
MsgBox("The string was found at position " pos) ; Reports different numbers, best we can do, see #41