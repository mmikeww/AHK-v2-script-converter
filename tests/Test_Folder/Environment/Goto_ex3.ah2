#Warn Unreachable, Off
myGui := Gui()
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Tag.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Test.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Tag1.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Test1.Bind("Normal"))
myGui.Show()

Goto("Somewhere")
Return

Somewhere:
Somewhere()
Return

Tag:
Tag()
return

Test:
Test()
return

Tag1:
Tag1()
return

Test1:
Test1()
return

;###############  V1toV2 FUNCS  ###############
Somewhere() { ; V1toV2: Lbl->Func
global
MsgBox("Test")
Return
}
;##############################################
Tag(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("tag")
return
}
;##############################################
Test(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("test")
return
}
;##############################################
Tag1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("tag1")
return
}
;##############################################
Test1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("test1")
return
}