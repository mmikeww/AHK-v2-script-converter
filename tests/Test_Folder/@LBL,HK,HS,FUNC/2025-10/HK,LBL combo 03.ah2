

guiclose() ; V1toV2: Gosub
return

guiclose:
guiclose()
return
~esc::HK1_esc()

;###############  V1toV2 FUNCS  ###############
guiclose() { ; V1toV2: Lbl->Func
global
HK1_esc()
}
;##############################################
HK1_esc() { ; V1toV2: HK->Func
global
MsgBox("`"exiting`"")
ExitApp()
}