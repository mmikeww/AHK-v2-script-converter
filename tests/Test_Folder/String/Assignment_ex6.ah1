MyStr := "Regex: /\(.*?\)/g"

MyVar := RegExReplace(MyStr, "/.*/\w+", "")

MsgBox % MyStr "`n" MyVar