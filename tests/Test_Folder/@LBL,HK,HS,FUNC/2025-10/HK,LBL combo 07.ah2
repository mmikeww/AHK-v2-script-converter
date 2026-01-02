#Warn Unreachable, Off
^l::HK1_l()
return

Label:
Label()
return

;###############  V1toV2 FUNCS  ###############
HK1_l() { ; V1toV2: HK->Func
global
MsgBox("Going to label")
Label() ; V1toV2: Goto->FuncCall
return
}
;##############################################
Label() { ; V1toV2: Lbl->Func
global
MsgBox("In Label")
}