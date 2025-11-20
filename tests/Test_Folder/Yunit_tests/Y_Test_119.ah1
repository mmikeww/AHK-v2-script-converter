Haystack = abcdefabcdef
Needle = cde
var = 2
StringGetPos, pos, Haystack, %Needle%,, %var%
if pos >= 0
    MsgBox, The string was found at position %pos%.