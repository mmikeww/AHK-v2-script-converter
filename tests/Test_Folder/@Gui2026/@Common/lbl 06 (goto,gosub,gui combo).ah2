; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",LBL2.Bind("Normal"))
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",LBL3.Bind("Normal"))
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",LBL4.Bind("Normal"))
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",LBL5.Bind("Normal"))
mV2Gui["1"].Show()

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