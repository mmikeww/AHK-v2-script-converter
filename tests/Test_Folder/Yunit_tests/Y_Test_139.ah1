OldStr := "The quick brown fox"
StringReplace, NewStr, OldStr, %A_Space%,, All
FileAppend, %NewStr%, *