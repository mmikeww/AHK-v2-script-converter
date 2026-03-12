; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","_Type"]] := mV2Gui["1"].Add("Radio","v_Type","Option 1")
mV2Gui["1"].Add("Radio",,"Option 2")
mV2GC[["1","CheckResponse"]] := mV2Gui["1"].Add("Button",,"Check Response")
mV2GC[["1","CheckResponse"]].OnEvent("Click",CheckResponse.Bind("Normal"))
mV2Gui["1"].Show()
Return

CheckResponse:
CheckResponse()
return

;###############  V1toV2 FUNCS  ###############
CheckResponse(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
_Type := mV2GC[["1","_Type"]].Value
If (_Type = 1) {
  MsgBox("You Selected Option 1")
} else {
  MsgBox("You Selected Option 2")
}
}