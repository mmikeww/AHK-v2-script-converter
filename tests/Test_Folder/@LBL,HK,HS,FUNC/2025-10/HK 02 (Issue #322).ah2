; https://github.com/mmikeww/AHK-v2-script-converter/issues/322

f::HK1_f()
Return

g::HK2_g()

h::HK3_h()
Return

;###############  V1toV2 FUNCS  ###############
HK1_f() { ; V1toV2: HK->Func
global
MsgBox("You pressed f!")
Return
}
;##############################################
HK2_g() { ; V1toV2: HK->Func
global
MsgBox("You pressed g!")
return
}
;##############################################
HK3_h() { ; V1toV2: HK->Func
global
HK1_f() ; V1toV2: Gosub
HK2_g() ; V1toV2: Gosub
Send("f")
Send("g")
HK1_f() ; V1toV2: Goto->FuncCall
Return
}