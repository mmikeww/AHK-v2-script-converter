; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-3244926208

A() ; V1toV2: Gosub ; Runs A then returns here
Goto("A")
Return ; V1toV2: post-return for Goto ; Runs A then exits at return
A() ; V1toV2: Gosub ; Shouldn't run (but does in v2 conv)

A:
A()
Return

;###############  V1toV2 FUNCS  ###############
A() { ; V1toV2: Lbl->Func
global
MsgBox()
Return
}