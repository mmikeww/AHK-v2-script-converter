Haystack = abcdefghijklmnopqrs
Needle = def
StringGetPos, pos, Haystack, %Needle%
if pos >= 0
    MsgBox, The string was found at position %pos%.