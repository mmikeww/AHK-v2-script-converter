#Warn Unreachable, Off
myGui := Gui()
ogcTextC := myGui.Add("Text", "vTextC", "HWND Test")
ogcEditFirstName := myGui.Add("Edit", "vFirstName"), test := ogcEditFirstName.hwnd
ogcButtonSubmit := myGui.Add("Button", , "Submit")
ogcButtonSubmit.OnEvent("Click", Clicked.Bind("Normal"))
myGui.Show()
Return

Clicked:
Clicked()
Return

;###############  V1toV2 FUNCS  ###############
Clicked(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox(test)
Return
}