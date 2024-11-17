Haystack = abcdefabcdef
Needle = cde
var = 1
StringGetPos, pos, Haystack, %Needle%,, % var+2
if pos >= 0
    FileAppend, The string was found at position %pos%., *