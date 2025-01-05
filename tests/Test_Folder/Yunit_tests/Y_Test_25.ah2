list := "one,two,three"
list := StrReplace(list, ",", ",",, &ErrorLevel)
FileAppend(ErrorLevel, "*")