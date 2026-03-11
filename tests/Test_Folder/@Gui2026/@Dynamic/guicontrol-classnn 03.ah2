; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Name"]] := mV2Gui["1"].Add("Button","w110","Name")
mV2GC[["1","Name"]].OnEvent("Click",ButtonName.Bind("Normal"))
mV2GC[["1","changeButtonText"]] := mV2Gui["1"].Add("Button","w110","changeButtonText")
mV2GC[["1","changeButtonText"]].OnEvent("Click",changeButtonText.Bind("Normal"))
mV2Gui["1"].Add("Edit","R2 w110","Test`nTest")
mV2Gui["1"].Show("w140")
;changeButtonText()
Return

ButtonName:
ButtonName()
return

changeButtonText(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
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
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl)
}