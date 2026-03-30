#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Name"]] := mV2Gui[""].Add("Button","w110","Name")
mV2GC[["","Name"]].OnEvent("Click",ButtonName.Bind("Normal"))
mV2GC[["","changeButtonText"]] := mV2Gui[""].Add("Button","w110","changeButtonText")
mV2GC[["","changeButtonText"]].OnEvent("Click",changeButtonText.Bind("Normal"))
mV2Gui[""].Add("Edit","R2 w110","Test`nTest")
mV2Gui[""].Show("w140")
;changeButtonText()
Return

ButtonName:
ButtonName()
return

changeButtonText(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
  (IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
  static c := 0
  c++
  ; these track proper controls in real time
  ; with or without gui id, and with only classNN id
  fcV2GC("","Button2").Text := "Change Name (" c ")"
  fcV2GC("","Button1").Text := "Button1 (" c ")"
}

;###############  V1toV2 FUNCS  ###############
ButtonName(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl)
}