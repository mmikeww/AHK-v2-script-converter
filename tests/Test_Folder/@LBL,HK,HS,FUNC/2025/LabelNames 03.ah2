#Warn Unreachable, Off
; Part of issue #201
#Requires Autohotkey v2.0
; show foo bar

_1__miro__r() ; V1toV2: Gosub

MsgBox("bar")
Return

; label
_1__miro__r:
_1__miro__r()
Return

;###############  V1toV2 FUNCS  ###############
_1__miro__r() { ; V1toV2: Lbl->Func
global
MsgBox("foo")
Return
}