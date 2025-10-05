
LBL1:
LBL2:
MsgBox("hello2")

Goto("LBL5")

LBL3:
MsgBox("hello3")
LBL4:
MsgBox("hello4")
LBL5:
MsgBox("hello5")
; must be return here for gosub to return, otherwise gosub acts as goto
; if label being converted does not have return, add return below gosub