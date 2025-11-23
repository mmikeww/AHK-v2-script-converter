; https://github.com/mmikeww/AHK-v2-script-converter/issues/413

count := ""
if (count = "")
{
    Goto("init")
    Return ; V1toV2: post-return for Goto
}

; Controls
a::HK1_a()
init:
init()
return

b::HK2_b()
return

c::HK3_c()
return

; must move Goto below HK declaration
r::HK4_r()

;###############  V1toV2 FUNCS  ###############
HK1_a() { ; V1toV2: HK->Func
global
init()
}
;##############################################
init() { ; V1toV2: Lbl->Func
global
count := 1
return
}
;##############################################
HK2_b() { ; V1toV2: HK->Func
global
count++
return
}
;##############################################
HK3_c() { ; V1toV2: HK->Func
global
MsgBox(count)
return
}
;##############################################
HK4_r() { ; V1toV2: HK->Func
global
init() ; V1toV2: Goto->FuncCall  ; reset
}