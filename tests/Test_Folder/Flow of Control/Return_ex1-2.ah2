MyFunc() {
	ToReturn := "TestError"
	Return Trim(ToReturn, "Error")
}

MsgBox(MyFunc())

MsgBox("Return, Test")