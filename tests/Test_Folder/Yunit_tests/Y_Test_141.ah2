OldStr := "The quick brown fox"
NewStr := StrReplace(OldStr, A_Space, "+",, &ErrorLevel)
MsgBox("number of replacements: " ErrorLevel)