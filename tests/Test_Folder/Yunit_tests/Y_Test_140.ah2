OldStr := "The quick brown fox"
; StrReplace() is not case sensitive
; check for StringCaseSense in v1 source script
; and change the CaseSense param in StrReplace() if necessary
NewStr := StrReplace(OldStr, A_Space, "+",,, 1)
FileAppend(NewStr, "*")