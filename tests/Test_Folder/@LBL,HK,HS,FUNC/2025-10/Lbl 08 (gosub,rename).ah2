#Warn Unreachable, Off
; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-2289653604

MyFunc__() ; V1toV2: Gosub
MsgBox("C")
MyFunc2__() ; V1toV2: Gosub

MyFunc__:
MyFunc__()
return
MyFunc2__:
MyFunc2__()
return
MyFunc3__:
MyFunc3__()
Return

;###############  V1toV2 FUNCS  ###############
MyFunc__() { ; V1toV2: Lbl->Func
global
MsgBox("A")
MyFunc2__()
}
;##############################################
MyFunc2__() { ; V1toV2: Lbl->Func
global
MsgBox("B")
MyFunc3__()
}
;##############################################
MyFunc3__() { ; V1toV2: Lbl->Func
global
MsgBox("D")
Return
}

; A > B > D > C > B > D > A > B > D