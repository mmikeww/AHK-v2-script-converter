; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
mV2Gui["guiName"] := NewV2Gui("guiName")
mV2GC[["guiName","PressMe"]] := mV2Gui["guiName"].Add("Button","w100","PressMe")
mV2GC[["guiName","PressMe"]].OnEvent("Click",PressLabel.Bind("Normal"))
mV2Gui["guiName"].Show()

return
PressLabel(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
  ; v2 conversion will cross reference ctrl attributes
  static c := 0
  if (++c<2) {
     mV2GC[["guiName","PressMe"]].Text := "Press Again!"
  } else {
    ; match dynamic button name
    val := (c>2) ? " " c-1 : ""
    fcV2GC("guiName","Press Again!" val).Text := "Press Again! " c ; V1toV2: Verify that control [% "Press Again!" val] is accurate
  }
}