#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",LBL2.Bind("Normal"))
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",LBL3.Bind("Normal"))
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",LBL4.Bind("Normal"))
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",LBL5.Bind("Normal"))
mV2Gui[""].Show()

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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("LBL1")
LBL2()
}
;##############################################
LBL2(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("LBL2")
LBL3()
}
;##############################################
LBL3(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("LBL3")
LBL4()
}
;##############################################
LBL4(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("LBL4")
return
}
;##############################################
LBL5(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("LBL5")
return
}