#Warn Unreachable, Off

return ; V1toV2: remove if unnecessary
^q::
{
  MsgBox("I am HK ^q")
  LBL1() ; V1toV2: remove if unnecessary
}

; LBL1 will not execute during script ini (due to HK above)
LBL1:
LBL1()
return ; v1 execution continues past this point

LBL2:
LBL2()
return

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

V1toV2_GblCode_002:
V1toV2_GblCode_002()
return

;###############  V1toV2 FUNCS  ###############
LBL1()
{ ; V1toV2: Lbl->Func
 global ; v1 lbl braces wont restrict execution within brace boundaries
  MsgBox("I am LBL1, but execute with HK ^q")
  ; global code following lbl/HK with braces, is part of lbl/HK
 LBL2()
}
;##############################################
LBL2()
{ ; V1toV2: Lbl->Func
  global
  MsgBox("I am LBL2, but execute with LBL1")
  V1toV2_GblCode_001()
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
; this will only execute as part of label above it
MsgBox("I am global, but execute with LBL2")
return
}
;##############################################
V1toV2_GblCode_002() { ; V1toV2: Lbl->Func
global
; this will not be executed at script startup
MsgBox("I cannot be shown")
}