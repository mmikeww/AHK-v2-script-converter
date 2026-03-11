; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Button1"]] := mV2Gui["1"].Add("Button",,"Button 1")
mV2GC[["1","Button1"]].OnEvent("Click",b1.Bind("Normal"))
mV2GC[["1","e1"]] := mV2Gui["1"].Add("Edit","ve1","Some Text")
mV2Gui["1"].Show()
Return

b1:
b1()
return

;###############  V1toV2 FUNCS  ###############
b1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
Var := "Focus" ; This fix works with focus, others won't
mV2GC[["1","e1"]].%var%() ; V1toV2: SubCommand passed as variable, check variable contents and docs
}
