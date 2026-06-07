#Warn Unreachable, Off

return ; V1toV2: remove if unnecessary
^q::
{
  var := "-10"
  MsgBox("I am HK ^q")

  LBL1:
  MsgBox("I am nested LBL1" . var)

  LBL2:
  MsgBox("I am nested LBL2" . var)
  V1toV2_GblCode_001() ; V1toV2: remove if unnecessary
}

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

;###############  V1toV2 FUNCS  ###############
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
MsgBox("I am global, but execute with HK ^q")
return
}