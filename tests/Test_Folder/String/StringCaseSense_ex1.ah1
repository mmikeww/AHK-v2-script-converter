StringCaseSense, on
Haystack = abcdefabcDEF
Needle = DEF
StringGetPos, pos, Haystack, %Needle%
MsgBox, The string was found at position %pos%