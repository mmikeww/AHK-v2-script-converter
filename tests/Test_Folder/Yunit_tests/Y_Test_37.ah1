Haystack = abcdefghijklmnopqrs
StringGetPos, pos, Haystack, % "def"
if pos >= 0
    MsgBox, The string was found at position %pos%.