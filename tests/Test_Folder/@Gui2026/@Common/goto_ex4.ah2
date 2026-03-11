; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","btn"]] := mV2Gui["1"].Add("Button",,"btn")
mV2GC[["1","btn"]].OnEvent("Click",Lbl.Bind("Normal"))
mV2Gui["1"].Show()

Goto("Lbl")
Return ; V1toV2: post-return for Goto
;Goto, Lbl

Lbl:
Lbl()
Return

;###############  V1toV2 FUNCS  ###############
Lbl(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox()
Return
}