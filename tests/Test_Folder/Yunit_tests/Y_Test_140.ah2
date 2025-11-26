OldStr := "The quick brown fox"
NewStr := StrReplace(OldStr, A_Space, "+",,, 1)
MsgBox(NewStr)