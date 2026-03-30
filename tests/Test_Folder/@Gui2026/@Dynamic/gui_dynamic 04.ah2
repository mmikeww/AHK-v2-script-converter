#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
; https://www.autohotkey.com/boards/viewtopic.php?p=581354#p581354

Margin := 20
shiftY := -25
Loop 5 {
  If (!HasV2Gui("ClipGui")) {
    mV2Gui["ClipGui"] := NewV2Gui("ClipGui")
  }
  mV2GC[["ClipGui","CH" . A_Index]] := mV2Gui["ClipGui"].Add("Text"," +Border Center x" . Margin . " y" . Margin + (shiftY += 25) . " w" . 75 . " h" . 20 . " vCH" . A_Index,"Text " A_Index)
}
mV2Gui["ClipGui"].Show("w200 h200")

fcV2GC("ClipGui","CH2").Text := "Changed!" ; V1toV2: Verify that control [CH2] is accurate
fcV2GC("ClipGui","Static5").Text := "Changed!"
