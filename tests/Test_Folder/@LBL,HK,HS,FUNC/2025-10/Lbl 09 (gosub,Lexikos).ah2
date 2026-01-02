#Warn Unreachable, Off
; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-2495219614

LabelA() ; V1toV2: Gosub
MsgBox("After Label")
LabelA() ; V1toV2: Gosub ; Implied
Return ; Implied
LabelA:
LabelA()
Return

;###############  V1toV2 FUNCS  ###############
LabelA() { ; V1toV2: Lbl->Func
global
MsgBox("In Label")
Return
}