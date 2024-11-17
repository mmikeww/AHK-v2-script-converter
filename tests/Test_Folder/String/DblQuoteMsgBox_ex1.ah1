F1:: MsgBox % """" ; "
F2:: MsgBox % "abc""123" ; abc"123
F3:: MsgBox % "abc""123" MyFunc("", "123""abc") "" ; abc"123123"abc

MyFunc(a, b) {
  return a b
}