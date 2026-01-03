#Warn Unreachable, Off

label() ; V1toV2: Gosub
return

+up::
+down::HK2_down()

label:
label()
return

;###############  V1toV2 FUNCS  ###############
HK2_down() { ; V1toV2: HK->Func
global
MsgBox("shift+arrow")
label()
}
;##############################################
label() { ; V1toV2: Lbl->Func
global
MsgBox("label")
}