; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",Tag.Bind("Normal"))
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",Test.Bind("Normal"))
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",Tag1.Bind("Normal"))
mV2GC[["1","Test"]] := mV2Gui["1"].Add("Button",,"Test")
mV2GC[["1","Test"]].OnEvent("Click",Test1.Bind("Normal"))
mV2Gui["1"].Show()

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