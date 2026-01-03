#Warn Unreachable, Off

label2() ; V1toV2: Gosub

label1:
label1()
return

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

; comment preceding label 2

label2:
label2()
return

;###############  V1toV2 FUNCS  ###############
label1()
{ ; V1toV2: Lbl->Func
;global
MsgBox("label1 within braces")
return
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
; global code between labels

MsgBox("global code 1 (won't auto-execute)")
return
}
;##############################################
label2() { ; V1toV2: Lbl->Func
global
MsgBox("label2")
return
}