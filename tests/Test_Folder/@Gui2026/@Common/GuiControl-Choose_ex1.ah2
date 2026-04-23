#Warn Unreachable, Off
myGui := Gui()
ogcDDLList := myGui.Add("DDL", "vList", ["A", "B", "C"])
ogcDDLList.OnEvent("Change", Handler.Bind("Normal"))
ogcButton1 := myGui.Add("Button", , "1")
ogcButton1.OnEvent("Click", Button1.Bind("Normal"))
ogcButtonA := myGui.Add("Button", "xp+50 yp", "A")
ogcButtonA.OnEvent("Click", ButtonA.Bind("Normal"))
ogcButton2 := myGui.Add("Button", "xp-50 yp+25", "2")
ogcButton2.OnEvent("Click", Button2.Bind("Normal"))
ogcButtonB := myGui.Add("Button", "xp+50 yp", "B")
ogcButtonB.OnEvent("Click", ButtonB.Bind("Normal"))
ogcButton3 := myGui.Add("Button", "xp-50 yp+25", "3")
ogcButton3.OnEvent("Click", Button3.Bind("Normal"))
ogcButtonC := myGui.Add("Button", "xp+50 yp", "C")
ogcButtonC.OnEvent("Click", ButtonC.Bind("Normal"))
myGui.Show()
return

Button1:
Button1()
return
Button2:
Button2()
return
Button3:
Button3()
return

ButtonA:
ButtonA()
return
ButtonB:
ButtonB()
return
ButtonC:
ButtonC()
return

Handler:
Handler()
return

;###############  V1toV2 FUNCS  ###############
Button1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ogcDDLList.Choose(1)
return
}
;##############################################
Button2(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ogcDDLList.Choose("B")
return
}
;##############################################
Button3(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ogcDDLList.Choose(3)
return
}
;##############################################
ButtonA(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ControlChooseIndex(1, ogcDDLList)
return
}
;##############################################
ButtonB(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ControlChooseString("B", ogcDDLList)
return
}
;##############################################
ButtonC(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ControlChooseIndex(3, ogcDDLList)
return
}
;##############################################
Handler(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox()
}