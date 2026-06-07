

gosub LBL2
gosub LBL1a
return

^q:: ; ALSO - how to handle this hotkey/label combo?
MsgBox % "HK ONLY"
LBL1a:	; fall thru 1
MsgBox % "HK1 & LBL1a"
LBL1b:	; fall thru 2
MsgBox % "HK1, LBL1a, LBL1b"
; no exit cmd

; cannot be part of new gosub function after conversion
; moving this out of the way is the easiest solution.
func1() {
	MsgBox % "func1"
}

; will need to be called by HK and LBL1
LBL2:
MsgBox % "LBL2"
; no exit cmd

; cannot be part of new gosub function after conversion
; moving this out of the way is the easiest solution.
func2() {
	MsgBox % "func2"
}

; still global space and HK1/LBL1/LB2 jumps over func1 and func2 and lands here
; this needs to be executed as part of HK1/LBL1/LBL2 functions after conversion
MsgBox % "AFTER FUNC2"  ; global code that will execute with labels and hotkey above func1/2
return

; new location for FUNC1 and FUNC2


func3() {
	MsgBox % "func3"
}