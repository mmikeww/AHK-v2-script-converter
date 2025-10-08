

return
MouseClickHandler: ; label comes before HK triggers
MouseClickHandler()
    return

^LButton::MouseClickHandler() ; V1toV2: Gosub ; Single-line gosub
Return

^RButton::HK2_RButton()

;###############  V1toV2 FUNCS  ###############
MouseClickHandler() { ; V1toV2: Lbl->Func
global
    MsgBox("MouseClickHandler")
    return
}
;##############################################
HK2_RButton() { ; V1toV2: HK->Func
global
MouseClickHandler() ; V1toV2: Gosub ; Multi-line gosub
Return
}
