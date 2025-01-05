A_StringCaseSense := true
Haystack := "abcdefabcDEF"
Needle := "DEF"
pos := InStr(Haystack, Needle, A_StringCaseSense) - 1
MsgBox("The string was found at position " pos)