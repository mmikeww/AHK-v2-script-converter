

LBL2() ; V1toV2:Gosub
LBL1a() ; V1toV2:Gosub
return

^q::HK1_q() ; ALSO - how to handle this hotkey/label combo?
LBL1a:	; fall thru 1
LBL1a()
return
LBL1b:	; fall thru 2
LBL1b()
return
; no exit cmd

; cannot be part of new gosub function after conversion
; moving this out of the way is the easiest solution.
func1() {
	MsgBox("func1")
}

; will need to be called by HK and LBL1
LBL2:
LBL2()
return
; no exit cmd

; cannot be part of new gosub function after conversion
; moving this out of the way is the easiest solution.
func2() {
	MsgBox("func2")
}

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

; new location for FUNC1 and FUNC2


func3() {
	MsgBox("func3")
}

;###############  V1toV2 FUNCS  ###############
HK1_q() { ; V1toV2: HK->Func
global
MsgBox("HK ONLY")
LBL1a()
}
;##############################################
LBL1a() { ; V1toV2: Lbl->Func
global
MsgBox("HK1 & LBL1a")
LBL1b()
}
;##############################################
LBL1b() { ; V1toV2: Lbl->Func
global
MsgBox("HK1, LBL1a, LBL1b")
LBL2()
}
;##############################################
LBL2() { ; V1toV2: Lbl->Func
global
MsgBox("LBL2")
V1toV2_GblCode_001()
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
; still global space and HK1/LBL1/LB2 jumps over func1 and func2 and lands here
; this needs to be executed as part of HK1/LBL1/LBL2 functions after conversion
MsgBox("AFTER FUNC2")  ; global code that will execute with labels and hotkey above func1/2
return
}