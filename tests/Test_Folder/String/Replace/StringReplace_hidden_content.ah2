Str := "AAA"
SearchText := "A"
ReplaceText := "Z"
Options := "All"
if (not Options)
    Str := StrReplace(Str, SearchText, ReplaceText,,, 1)
else
    Str := StrReplace(Str, SearchText, ReplaceText,, &ErrorLevel)
MsgBox(Str)