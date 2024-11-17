Haystack = abcdefabcdef
Needle = cde
StringGetPos, pos, Haystack, %Needle%,, 4
if pos >= 0
    FileAppend, The string was found at position %pos%., *