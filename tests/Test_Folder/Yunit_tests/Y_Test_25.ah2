list := "one,two,three"
list := StrReplace(list, ",", ",",, &ErrorLevel)
MsgBox(ErrorLevel)