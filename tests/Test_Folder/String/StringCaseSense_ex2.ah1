StringCaseSense, On

var := "abc"

IfInString, var, ABC
  MsgBox true

StringGetPos, msg, var, ABC
MsgBox % msg

StringReplace, msg, var, ABC
MsgBox % msg

msg := StrReplace("aA", "A")
MsgBox % msg

msg := InStr("aA", "A")
MsgBox % msg