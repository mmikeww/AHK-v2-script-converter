Haystack := "abcdefabcdef"
Needle := "cde"
pos := InStr(Haystack, Needle,, -1*((0)+1), -2) - 1
if (pos >= 0)
    FileAppend("The string was found at position " pos ".", "*")