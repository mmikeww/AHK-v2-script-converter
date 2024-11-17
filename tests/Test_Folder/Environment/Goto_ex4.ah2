myGui := Gui()
ogcButtonbtn := myGui.Add("Button", , "btn")
ogcButtonbtn.OnEvent("Click", Lbl.Bind("Normal"))
myGui.Show()

Lbl()
;Goto, Lbl

Lbl(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox()
Return
} ; V1toV2: Added bracket in the end