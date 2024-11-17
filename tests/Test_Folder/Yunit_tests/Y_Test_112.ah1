Haystack = abcdefghijklmnopqrs
Needle = def
StringGetPos, pos, Haystack, %Needle%
if pos >= 0
    FileAppend, The string was found at position %pos%., *