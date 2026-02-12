#Warn Unreachable, Off
myGui := Gui()
ogcButtonbtn := myGui.Add("Button", , "btn")
ogcButtonbtn.OnEvent("Click", Lbl.Bind("Normal"))
myGui.Show()

Goto("Lbl")
Return ; V1toV2: post-return for Goto
;Goto, Lbl

Lbl:
Lbl()
Return

;###############  V1toV2 FUNCS  ###############
Lbl(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox()
Return
}