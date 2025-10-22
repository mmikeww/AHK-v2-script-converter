^l::HK1_l()
return

GuiClose:
GuiClose()
return

;###############  V1toV2 FUNCS  ###############
HK1_l() { ; V1toV2: HK->Func
global
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.Show("w100 h100")
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("Gui Closed")
}