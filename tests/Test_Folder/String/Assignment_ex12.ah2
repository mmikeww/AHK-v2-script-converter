; test for v1v2_FixLegAssignments() and v1v2_FixExpAssignments

lVar1 := "legStr, comma does not allow chained leg assign"		; comment 1
lVar2 := "...leg assign must be on its own line"				; comment 2

var:= "", eVar:= eVar0:="000", eVar1 := 001, eVar2  := 2 , eVar3 := "test3", eVar4 := eVar2 . eVar1					; comment 4
, eVar5:="", eVar6 := eVar3 . eVar4, eVar7 := "" . eVar0 . eVar6, eVar8 := lVar1 . "`n`n" . eVar7 . "`n`n" . lVar2	; comment 5

MsgBox(eVar)	; does not work in v1, but will in v2 converted
MsgBox(eVar8)	; does not work in v1, but will in v2 converted


lVar3 := "escaped semi-colon `; is part of str `;"				; comment 1
eVar9 := "`; test escaped `; semi-colons `;" ; comment 2	; comment 3

MsgBox(lVar3)
MsgBox(eVar9)