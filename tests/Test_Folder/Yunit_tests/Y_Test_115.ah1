Haystack = abcdefghijklmnopqrs
Needle = xyz
StringGetPos, pos, Haystack, %Needle%
FileAppend, The string was found at position %pos%., *