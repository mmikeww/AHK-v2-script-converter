Join(a, ByRef b) {
  b .= a
}

Str := 123

Join("abc", Str)

MsgBox % Str