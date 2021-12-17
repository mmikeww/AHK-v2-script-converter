Haystack := "The Quick Brown Fox Jumps Over the Lazy Dog"
Needle := "the"
MsgBox(InStr(Haystack, Needle, false, 1, 2)) ; case insensitive search, return start position of second occurence
MsgBox(InStr(Haystack, Needle, true)) ; case sensitive search, return start position of first occurence, same result as above
