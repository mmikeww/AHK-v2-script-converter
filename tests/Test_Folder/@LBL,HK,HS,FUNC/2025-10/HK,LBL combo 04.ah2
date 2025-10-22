LBL2() ; V1toV2: Gosub
LBL1() ; V1toV2: Gosub
close() ; V1toV2: Gosub
return

close:
close()
return
~esc::HK1_esc()
ExitApp()

^q::HK2_q()
LBL1:
LBL1()
return
; no exit cmd

; cannot be part of new gosub function after conversion
func1() {
	MsgBox("func1")
}

; will need to be called by HK and LBL1
LBL2:
LBL2()
return
; no exit cmd

; cannot be part of new gosub function after conversion
func2() {
	MsgBox("func2")
}

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

func3() {
	MsgBox("func3")
}

;###############  V1toV2 FUNCS  ###############
close() { ; V1toV2: Lbl->Func
global
HK1_esc()
}
;##############################################
HK1_esc() { ; V1toV2: HK->Func
global
MsgBox("exiting")
ExitApp()
}
;##############################################
HK2_q() { ; V1toV2: HK->Func
global
LBL1()
}
;##############################################
LBL1() { ; V1toV2: Lbl->Func
global
MsgBox("HK1 & LBL1")
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