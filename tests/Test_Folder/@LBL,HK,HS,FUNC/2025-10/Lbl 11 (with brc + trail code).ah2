;Onexit, exit
return

+lbutton::	; comment 1
!lbutton::HK2_lbutton()	; comment 2

; label with braces
label_with_braces:
label_with_braces()
return

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

;return

func1() {
	MsgBox("func1")
}

V1toV2_GblCode_002:
V1toV2_GblCode_002()
return

exit:
exit()
	ExitApp()
return

;###############  V1toV2 FUNCS  ###############
HK2_lbutton() { ; V1toV2: HK->Func
global

	label_with_braces() ; V1toV2: Gosub

return
}
;##############################################
label_with_braces()
{ ; V1toV2: Lbl->Func
;global
	MsgBox("label with braces")
	; return

V1toV2_GblCode_001()
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
; comment after label_with_braces
;return

MsgBox("after label_with_braces")
V1toV2_GblCode_002()
}
;##############################################
V1toV2_GblCode_002() { ; V1toV2: Lbl->Func
global
MsgBox("after func1")
exit()
}
;##############################################
exit() { ; V1toV2: Lbl->Func
global
	MsgBox("exiting")
	ExitApp()
}
