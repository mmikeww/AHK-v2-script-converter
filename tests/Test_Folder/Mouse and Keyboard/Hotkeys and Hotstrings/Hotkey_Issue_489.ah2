#Warn Unreachable, Off
goto("lblEnd")
return

^q::
{
MsgBox("HK")
goto("lbl1")
return

lbl1:
MsgBox("Nested Label 1")
goto("lbl2")
return

lbl2:
MsgBox("Nested Label 2")
return
V1toV2_GblCode_001() ; V1toV2: remove if unnecessary
}

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

lblEnd:
lblEnd()
return

;###############  V1toV2 FUNCS  ###############
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
MsgBox("Global")
return
}
;##############################################
lblEnd() { ; V1toV2: Lbl->Func
global
}