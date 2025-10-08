myGui := Gui()
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", LBL2.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", LBL3.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", LBL4.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", LBL5.Bind("Normal"))
myGui.Show()

LBL2() ; V1toV2: Gosub

Goto("LBL1")
Return

LBL1:
LBL1()
return

LBL2:
LBL2()
return

LBL3:
LBL3()
return

LBL4:
LBL4()
return

LBL5:
LBL5()
return

;###############  V1toV2 FUNCS  ###############
LBL1() { ; V1toV2: Lbl->Func
global
MsgBox("LBL1")
LBL2()
}
;##############################################
LBL2(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("LBL2")
LBL3()
}
;##############################################
LBL3(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("LBL3")
LBL4()
}
;##############################################
LBL4(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("LBL4")
return
}
;##############################################
LBL5(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("LBL5")
return
}