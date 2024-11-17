OldStr := "The quick brown fox"
StringReplace, NewStr, OldStr, % " ", % "+", All
FileAppend, %NewStr%, *