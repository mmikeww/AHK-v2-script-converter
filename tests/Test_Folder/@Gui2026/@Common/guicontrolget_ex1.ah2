#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","_Type"]] := mV2Gui[""].Add("Radio","v_Type","Option 1")
mV2Gui[""].Add("Radio",,"Option 2")
mV2GC[["","CheckResponse"]] := mV2Gui[""].Add("Button",,"Check Response")
mV2GC[["","CheckResponse"]].OnEvent("Click",CheckResponse.Bind("Normal"))
mV2Gui[""].Show()
Return

CheckResponse:
CheckResponse()
return

;###############  V1toV2 FUNCS  ###############
CheckResponse(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
_Type := mV2GC[["","_Type"]].Value
If (_Type = 1) {
  MsgBox("You Selected Option 1")
} else {
  MsgBox("You Selected Option 2")
}
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    _Type := ""
}