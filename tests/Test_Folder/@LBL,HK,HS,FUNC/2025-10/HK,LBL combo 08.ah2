label1() ; V1toV2: Gosub
return

label1:
label1()
return

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

V1toV2_GblCode_002:
V1toV2_GblCode_002()
return

q::
func1(*){
w := 10
h := 20
MsgBox("hotkey")
return {w:w,h:h}
}

;###############  V1toV2 FUNCS  ###############
label1() { ; V1toV2: Lbl->Func
global
MsgBox("label1")
return
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
; global code
MsgBox("global1")
return
}
;##############################################
V1toV2_GblCode_002() { ; V1toV2: Lbl->Func
global
MsgBox("global2")
return
}