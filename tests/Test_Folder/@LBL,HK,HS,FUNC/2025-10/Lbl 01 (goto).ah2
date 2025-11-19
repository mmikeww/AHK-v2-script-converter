
LBL1:
LBL2:
LBL2()
Return

LBL3:
LBL3()
return
LBL4:
LBL4()
return
LBL5:
LBL5()
return

;###############  V1toV2 FUNCS  ###############
LBL2() { ; V1toV2: Lbl->Func
global
MsgBox("hello2")

LBL5() ; V1toV2: Goto->FuncCall
Return ; V1toV2: post-return for Goto
}
;##############################################
LBL3() { ; V1toV2: Lbl->Func
global
MsgBox("hello3")
LBL4()
}
;##############################################
LBL4() { ; V1toV2: Lbl->Func
global
MsgBox("hello4")
LBL5()
}
;##############################################
LBL5() { ; V1toV2: Lbl->Func
global
MsgBox("hello5")
}
; must be return here for gosub to return, otherwise gosub acts as goto
; if label being converted does not have return, add return below gosub