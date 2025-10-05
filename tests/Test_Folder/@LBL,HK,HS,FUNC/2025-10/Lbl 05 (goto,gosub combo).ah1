
gosub LBL3
goto LBL1
gosub LBL5	; never gets here due to goto above

; comment before 1
LBL1:
; comment after 1, before 2
LBL2:
; comment in 2
MsgBox % "LBL1 and LBL2"
return

LBL3:
; comment after 3, before 4
LBL4:
; comment in 4
MsgBox % "LBL3 and LBL4"

LBL5:
; comment after 5, before 6
LBL6:
; comment in 6
MsgBox % "LBL5 and LBL6"
return

; comment before 7
LBL7:
; comment in 7
MsgBox % "LBL7"	; never executed