Haystack := "abcdefghijklmnopqrs"
pos := InStr(Haystack, "def") - 1
if (pos >= 0)
    MsgBox("The string was found at position " pos ".")