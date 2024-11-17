Haystack = abcdefabcdefabcdef
Needle = cde
var = 0
StringGetPos, pos, Haystack, %Needle%, R2, var+2
if pos >= 0
    FileAppend, The string was found at position %pos%., *