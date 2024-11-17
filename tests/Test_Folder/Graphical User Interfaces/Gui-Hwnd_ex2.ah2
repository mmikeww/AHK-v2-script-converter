myGui := Gui()
ogcTextC := myGui.Add("Text", "vTextC", "HWND Test")
ogcEditFirstName := myGui.Add("Edit", "vFirstName")
test := ogcEditFirstName.hwnd
ogcButtonSubmit := myGui.Add("Button", , "Submit")
ogcButtonSubmit.OnEvent("Click", Clicked.Bind("Normal"))
myGui.Show()
Return

Clicked(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox(test)
Return
} ; V1toV2: Added bracket in the end