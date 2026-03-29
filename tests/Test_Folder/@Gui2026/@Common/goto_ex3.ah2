#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",Tag.Bind("Normal"))
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",Test.Bind("Normal"))
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",Tag1.Bind("Normal"))
mV2GC[["","Test"]] := mV2Gui[""].Add("Button",,"Test")
mV2GC[["","Test"]].OnEvent("Click",Test1.Bind("Normal"))
mV2Gui[""].Show()

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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Test")
Return
}
;##############################################
Tag(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("tag")
return
}
;##############################################
Test(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("test")
return
}
;##############################################
Tag1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("tag1")
return
}
;##############################################
Test1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("test1")
return
}