MyFunc() {
	global
	Return a := 1, b := a + 1
}
MyFunc()
MsgBox % a " " b

MyFunc2() {
	global d
	Return c := 1, d := c + 1
}
MyFunc2()
MsgBox % MyFunc2() " " d ; 1 2