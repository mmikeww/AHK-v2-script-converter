Haystack := "abcdefghijklmnopqrs"
Needle := "xyz"
pos := InStr(Haystack, Needle) - 1
FileAppend("The string was found at position " pos ".", "*")