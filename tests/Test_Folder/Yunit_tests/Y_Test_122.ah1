Haystack = abcdefabcdefabcdef
Needle = cde
StringGetPos, pos, Haystack, %Needle%, r2, 4
if pos >= 0
    FileAppend, The string was found at position %pos%., *