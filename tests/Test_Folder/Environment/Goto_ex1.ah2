^h::HK1_h()
Return ; V1toV2: post-return for Goto
V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

Start:
Start()
Return

;###############  V1toV2 FUNCS  ###############
HK1_h() { ; V1toV2: HK->Func
global
Start() ; V1toV2: Goto->FuncCall
Return ; V1toV2: post-return for Goto
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
MsgBox("Skipped")
Start()
}
;##############################################
Start() { ; V1toV2: Lbl->Func
global
MsgBox("This MsgBox is under the start label")
Return
}