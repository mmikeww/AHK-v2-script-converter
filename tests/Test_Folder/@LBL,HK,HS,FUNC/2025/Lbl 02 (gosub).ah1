

LBL1:
LBL2:
MsgBox % "hello2"

gosub LBL5
gosub LBL3

LBL3:
MsgBox % "hello3"
RETURN

LBL4:
MsgBox % "hello4"

LBL5:
MsgBox % "hello5"
; must be return/exit here for gosub to return, otherwise gosub acts as goto with no return
; if label being converted (and lower labels) do not have return, add return below gosub
RETURN