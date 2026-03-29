#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","btn"]] := mV2Gui[""].Add("Button",,"btn")
mV2GC[["","btn"]].OnEvent("Click",Lbl.Bind("Normal"))
mV2Gui[""].Show()

Goto("Lbl")
Return ; V1toV2: post-return for Goto
;Goto, Lbl

Lbl:
Lbl()
Return

;###############  V1toV2 FUNCS  ###############
Lbl(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox()
Return
}