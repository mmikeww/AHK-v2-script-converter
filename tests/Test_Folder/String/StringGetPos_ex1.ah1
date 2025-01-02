Haystack = FFFF
Needle = FF
StringGetPos, pos, Haystack, %Needle%, L2
if pos >= 0
     MsgBox, The string was found at position %pos%.