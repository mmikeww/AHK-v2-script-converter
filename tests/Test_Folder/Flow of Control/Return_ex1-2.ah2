MyFunc() {
	ToReturn := "TestError"
	Return (AHKv1v2_Temp := Trim(ToReturn, "Error"), AHKv1v2_Temp) ; V1toV2: Wrapped Multi-statement return with parentheses
}

MsgBox(MyFunc())

MsgBox("Return, Test")