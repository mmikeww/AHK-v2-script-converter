#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
mV2Gui["guiName"] := NewV2Gui("guiName",1)
mV2GC[["","PressMe"]] := mV2Gui[""].Add("Button","w100","PressMe")
mV2GC[["","PressMe"]].OnEvent("Click",PressLabel.Bind("Normal"))
mV2Gui[""].Show()

return
PressLabel(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
  (IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
  ; v2 conversion will cross reference ctrl attributes
  static c := 0
  if (++c<2) {
     mV2GC[["","PressMe"]].Text := "Press Again!"
  } else {
    ; match dynamic button name
    val := (c>2) ? " " c-1 : ""
    fcV2GC("guiName","Press Again!" val).Text := "Press Again! " c ; V1toV2: Verify that control [% "Press Again!" val] is accurate
  }
}