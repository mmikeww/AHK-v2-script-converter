OldStr := "The quick brown fox"
NewStr := StrReplace(OldStr, A_Space, "+",, &ErrorLevel)
FileAppend("number of replacements: " ErrorLevel, "*")