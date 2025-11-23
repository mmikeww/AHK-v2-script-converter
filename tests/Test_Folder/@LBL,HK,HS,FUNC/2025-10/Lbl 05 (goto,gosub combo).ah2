
LBL3() ; V1toV2: Gosub
goto("LBL1")
Return ; V1toV2: post-return for Goto
LBL5() ; V1toV2: Gosub	; never gets here due to goto above

; comment before 1
LBL1:
LBL1()
return
; comment after 1, before 2
LBL2:
LBL2()
return

LBL3:
LBL3()
return
; comment after 3, before 4
LBL4:
LBL4()
return

LBL5:
LBL5()
return
; comment after 5, before 6
LBL6:
LBL6()
return

; comment before 7
LBL7:
LBL7()
return

;###############  V1toV2 FUNCS  ###############
LBL1() { ; V1toV2: Lbl->Func
global
LBL2()
}
;##############################################
LBL2() { ; V1toV2: Lbl->Func
global
; comment in 2
MsgBox("LBL1 and LBL2")
return
}
;##############################################
LBL3() { ; V1toV2: Lbl->Func
global
LBL4()
}
;##############################################
LBL4() { ; V1toV2: Lbl->Func
global
; comment in 4
MsgBox("LBL3 and LBL4")
LBL6()
}
;##############################################
LBL5() { ; V1toV2: Lbl->Func
global
LBL6()
}
;##############################################
LBL6() { ; V1toV2: Lbl->Func
global
; comment in 6
MsgBox("LBL5 and LBL6")
return
}
;##############################################
LBL7() { ; V1toV2: Lbl->Func
global
; comment in 7
MsgBox("LBL7")	; never executed
}