Str := "AAA"
SearchText := "A"
ReplaceText := "Z"
Options := "All"
; StrReplace() is not case sensitive
; check for StringCaseSense in v1 source script
; and change the CaseSense param in StrReplace() if necessary
if (not Options)
    Str := StrReplace(Str, SearchText, ReplaceText,,, 1)
else
    Str := StrReplace(Str, SearchText, ReplaceText,, &ErrorLevel)
MsgBox(Str)