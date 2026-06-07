#Warn Unreachable, Off
; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-2216654421

MyFunc__() ; V1toV2: Gosub
MsgBox("C")
MyFunc2__() ; V1toV2: Gosub

MyFunc__:
MyFunc__()
return
MyFunc2__:
MyFunc2__()
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
Return
}

; A > B > C > B > A > B