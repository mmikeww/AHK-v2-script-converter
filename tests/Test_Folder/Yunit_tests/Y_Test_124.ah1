Haystack = abcdefabcdef
Needle = bcd
StringGetPos, pos, Haystack, %Needle%, R
if pos >= 0
    FileAppend, The string was found at position %pos%., *