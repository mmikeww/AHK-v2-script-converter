#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","ThingVar"]] := mV2Gui[""].Add("Button","vThingVar","Thing")
mV2GC[["","ThingVar"]].OnEvent("Click",Thing.Bind("Normal"))
mV2Gui[""].Show()
return

Thing:
Thing()
return

;###############  V1toV2 FUNCS  ###############
Thing(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Thing")
return
}