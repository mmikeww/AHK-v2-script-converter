StringCaseSense, on
Haystack = abcdefabcDEF
Needle = DEF
StringGetPos, pos, Haystack, %Needle%
MsgBox, The string was found at position %pos% ; Reports different numbers, best we can do, see #41