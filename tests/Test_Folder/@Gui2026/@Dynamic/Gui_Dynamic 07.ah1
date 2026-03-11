Gui, guiName:New
Gui, Add, Button, w100 gPressLabel, PressMe
Gui, Show

return
PressLabel() {
  ; v2 conversion will cross reference ctrl attributes
  static c := 0
  if (++c<2) {
     GuiControl,guiName:, PressMe, Press Again!
  } else {
    ; match dynamic button name
    val := (c>2) ? " " c-1 : ""
    GuiControl,guiName:Text, % "Press Again!" val, Press Again! %c%
  }
}