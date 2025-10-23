^h::HK1_h()
Return ; V1toV2: Add Return for Goto

Start:
Start()
Return

;###############  V1toV2 FUNCS  ###############
HK1_h() { ; V1toV2: HK->Func
global
Start() ; V1toV2: Goto->FuncCall
Return ; V1toV2: Add Return for Goto
MsgBox("Skipped")
}
;##############################################
Start() { ; V1toV2: Lbl->Func
global
MsgBox("This MsgBox is under the start label")
Return
}