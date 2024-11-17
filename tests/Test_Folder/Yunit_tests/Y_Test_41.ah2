OldStr := "The quick brown fox"
; V1toV2: StrReplace() is not case sensitive
; check for StringCaseSense in v1 source script
; and change the CaseSense param in StrReplace() if necessary
NewStr := StrReplace(OldStr, " ", "+")
FileAppend(NewStr, "*")