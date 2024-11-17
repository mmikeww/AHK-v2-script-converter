list := "one,two,three"
StringReplace list, list, `,, `,, UseErrorLevel
FileAppend, %ErrorLevel%, *