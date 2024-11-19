Join(a, &b) {
  b .= a
}

Str := 123

Join("abc", &Str)

MsgBox(Str)