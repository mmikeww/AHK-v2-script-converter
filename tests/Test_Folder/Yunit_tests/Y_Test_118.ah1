Haystack = abcdefabcdefabcdef
Needle = cde
StringGetPos, pos, Haystack, %Needle%, L2, 4
if pos >= 0
    MsgBox, The string was found at position %pos%.