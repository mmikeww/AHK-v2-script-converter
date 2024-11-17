Haystack = abcdefghijklmnopqrs
StringGetPos, pos, Haystack, % "def"
if pos >= 0
    FileAppend, The string was found at position %pos%., *