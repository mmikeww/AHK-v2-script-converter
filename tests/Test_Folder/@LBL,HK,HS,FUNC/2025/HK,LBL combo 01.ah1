

gosub LBL2
gosub LBL1
return

^q::
LBL1:
MsgBox % "HK1 & LBL1"

func1() {
	MsgBox % "func1"
}

; will need to be called by HK and LBL1
LBL2:
MsgBox % "LBL2"

func2() {
	MsgBox % "func2"
}

; global code and HK1/LBL1/LB2 jumps over func1 and func2 and lands here
; this needs to be executed as part of HK1/LBL1/LBL2 functions after conversion
MsgBox % "AFTER FUNC2"  ; global code that will execute with labels and hotkey above func1/2
return


func3() {
	MsgBox % "func3"
}