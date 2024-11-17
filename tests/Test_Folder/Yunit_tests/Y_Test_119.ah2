Haystack := "abcdefabcdef"
Needle := "cde"
var := "2"
pos := InStr(Haystack, Needle,, (var)+1) - 1
if (pos >= 0)
    FileAppend("The string was found at position " pos ".", "*")