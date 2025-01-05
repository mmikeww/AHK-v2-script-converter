OldStr := "The quick brown fox"
NewStr := StrReplace(OldStr, A_Space, "+")
FileAppend(NewStr, "*")