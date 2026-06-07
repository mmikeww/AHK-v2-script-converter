
; gosub -> label -> pass-through -> HK func
gosub A
return

A:
B:
C:	; v1 says this combo is invalid
^q::
HKfunc1() {
MsgBox % "HKfunc1"
}