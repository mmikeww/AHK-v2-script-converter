#Warn Unreachable, Off


LBL1:
LBL2:
LBL2()
return

LBL3:
LBL3()
RETURN

LBL4:
LBL4()
return

LBL5:
LBL5()
RETURN

;###############  V1toV2 FUNCS  ###############
LBL2() { ; V1toV2: Lbl->Func
global
MsgBox("hello2")

LBL5() ; V1toV2: Gosub
LBL3() ; V1toV2: Gosub
LBL3()
}
;##############################################
LBL3() { ; V1toV2: Lbl->Func
global
MsgBox("hello3")
RETURN
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
; must be return/exit here for gosub to return, otherwise gosub acts as goto with no return
; if label being converted (and lower labels) do not have return, add return below gosub
RETURN
}