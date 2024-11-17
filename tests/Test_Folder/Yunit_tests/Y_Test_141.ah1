OldStr := "The quick brown fox"
StringReplace, NewStr, OldStr, %A_Space%, +, UseErrorLevel
FileAppend, number of replacements: %ErrorLevel%, *