#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
E1 := "e1", E2 := "e2", E3 := "e3"
x := (A_ScreenWidth/2)-320

mV2Gui[""] := NewV2Gui("",1)
mV2Gui[""].add("text","y20","Edit these then press submit")
Loop 3
  ; has dynamic variable
  mV2GC[["","E" . A_Index]] := mV2Gui[""].add("edit","w100 vE" . A_Index,E%A_index%)
mV2GC[["","Submit"]] := mV2Gui[""].add("button",,"Submit")
mV2GC[["","Submit"]].OnEvent("Click",btnSubmit.Bind("Normal"))
mV2Gui[""].show("x" . x . " w175 h150")

return
btnSubmit:
btnSubmit()
return

;###############  V1toV2 FUNCS  ###############
btnSubmit(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)
varOutput := "New variable values:"
Loop 3
  varOutput .= ("`nE" A_Index ":   `"" E%A_index% "`"")
MsgBox(varOutput)
return
}
