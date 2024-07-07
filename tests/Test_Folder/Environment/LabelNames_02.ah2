; Part of issue #201
#Requires Autohotkey v2.0
; show foo bar

_1__miro__r()

MsgBox("bar")
Return

; label
_1__miro__r()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("foo")
Return
} ; V1toV2: Added bracket in the end