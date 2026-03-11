; https://www.autohotkey.com/boards/viewtopic.php?p=581354#p581354

Margin := 20
shiftY := -25
loop 5 {
  Gui, ClipGui: Add, Text, % " +Border Center x" . Margin . " y" . Margin + (shiftY += 25) . " w" . 75 . " h" . 20 . " vCH" . A_Index, % "Text " A_Index
}
Gui, ClipGui:Show, w200 h200

GuiControl ClipGui:Text, CH2, Changed!
GuiControl ClipGui:Text, Static5, Changed!
