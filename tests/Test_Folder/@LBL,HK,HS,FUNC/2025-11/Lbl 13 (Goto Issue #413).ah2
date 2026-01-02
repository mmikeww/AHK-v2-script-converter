#Warn Unreachable, Off
; https://github.com/mmikeww/AHK-v2-script-converter/issues/413

lbl1:
lbl1()
return

lbl2:
lbl2()
return

;###############  V1toV2 FUNCS  ###############
lbl1() { ; V1toV2: Lbl->Func
global
 n := 1
 if n
 {
  lbl2() ; V1toV2: Goto->FuncCall
  Return ; V1toV2: post-return for Goto
 }
 else
  ExitApp()
lbl2()
}
;##############################################
lbl2() { ; V1toV2: Lbl->Func
global
MsgBox("lbl2")
}