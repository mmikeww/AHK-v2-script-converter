; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
E1 := "e1", E2 := "e2", E3 := "e3"
x := (A_ScreenWidth/2)-320

mV2Gui["1"] := NewV2Gui("1")
mV2Gui["1"].add("text","y20","Edit these then press submit")
Loop 3
  ; has dynamic variable
  mV2GC[["1","E" . A_Index]] := mV2Gui["1"].add("edit","w100 vE" . A_Index,E%A_index%)
mV2GC[["1","Submit"]] := mV2Gui["1"].add("button",,"Submit")
mV2GC[["1","Submit"]].OnEvent("Click",btnSubmit.Bind("Normal"))
mV2Gui["1"].show("x" . x . " w175 h150")

return
btnSubmit:
btnSubmit()
return

;###############  V1toV2 FUNCS  ###############
btnSubmit(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
V2DynSubmitResult := V2DynSubmit(mV2Gui[gCurGuiID],0)
varOutput := "New variable values:"
Loop 3
  varOutput .= ("`nE" A_Index ":   `"" E%A_index% "`"")
MsgBox(varOutput)
return
}
