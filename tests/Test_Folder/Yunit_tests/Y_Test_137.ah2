OldStr := "The_quick_brown_fox"
; StrReplace() is not case sensitive
; check for StringCaseSense in v1 source script
; and change the CaseSense param in StrReplace() if necessary
NewStr := StrReplace(OldStr, "_",,,, 1)
FileAppend(NewStr, "*")