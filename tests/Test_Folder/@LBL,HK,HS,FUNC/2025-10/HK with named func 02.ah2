
; gosub -> label -> pass-through -> HK func
A() ; V1toV2:Gosub
return

A:
A()
return
B:
C:	; v1 says this combo is invalid
^q::
HKfunc1(*) {
MsgBox("HKfunc1")
}

;###############  V1toV2 FUNCS  ###############
A() { ; V1toV2: Lbl->Func
global
HKfunc1()
}