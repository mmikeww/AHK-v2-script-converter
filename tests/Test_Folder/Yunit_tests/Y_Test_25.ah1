list := "one,two,three"
StringReplace list, list, `,, `,, UseErrorLevel
MsgBox, %ErrorLevel%