list := "one,two,three"
; V1toV2: StrReplace() is not case sensitive
; check for StringCaseSense in v1 source script
; and change the CaseSense param in StrReplace() if necessary
list := StrReplace(list, ",", ",",, &ErrorLevel)
FileAppend(ErrorLevel, "*")