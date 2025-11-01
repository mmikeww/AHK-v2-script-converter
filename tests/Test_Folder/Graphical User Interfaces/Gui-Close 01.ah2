; fix for func params not being updated when label text-case does not match AHK map key

myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.SetFont("s12")
var:="test"
ogctexttxt := myGui.add("text", "vtxt center", var)
myGui.show()
return

guiclose:
guiclose()
ExitApp()
return

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}