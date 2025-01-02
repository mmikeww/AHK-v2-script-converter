MyVar := FileSelect()
If ((MyVar is String and MyVar = "") or (MyVar is Array and MyVar.Length = 0)) {
  ErrorLevel := 1
} else {
  ErrorLevel := 0
}
MsgBox(ErrorLevel)