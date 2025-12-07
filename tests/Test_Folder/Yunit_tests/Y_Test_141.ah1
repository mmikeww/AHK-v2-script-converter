OldStr := "The quick brown fox"
StringReplace, NewStr, OldStr, %A_Space%, +, UseErrorLevel
MsgBox, number of replacements: %ErrorLevel%