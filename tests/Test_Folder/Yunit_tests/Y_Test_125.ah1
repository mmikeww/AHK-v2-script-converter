Haystack = abcdefabcdef
Needle = bcd
StringGetPos, pos, Haystack, %Needle%, 1
if pos >= 0
    FileAppend, The string was found at position %pos%., *