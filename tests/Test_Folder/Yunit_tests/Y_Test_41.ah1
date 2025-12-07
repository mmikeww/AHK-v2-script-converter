OldStr := "The quick brown fox"
StringReplace, NewStr, OldStr, % " ", % "+", All
MsgBox, %NewStr%