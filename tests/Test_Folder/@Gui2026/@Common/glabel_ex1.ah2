; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Thing"]] := mV2Gui["1"].Add("Button","vThing","Thing")
mV2GC[["1","Thing"]].OnEvent("Click",Thing.Bind("Normal"))
mV2Gui["1"].Show()
return

Thing:
Thing()
return

;###############  V1toV2 FUNCS  ###############
Thing(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Thing")
return
}