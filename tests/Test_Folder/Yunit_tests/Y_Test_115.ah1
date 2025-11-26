Haystack = abcdefghijklmnopqrs
Needle = xyz
StringGetPos, pos, Haystack, %Needle%
MsgBox, The string was found at position %pos%.