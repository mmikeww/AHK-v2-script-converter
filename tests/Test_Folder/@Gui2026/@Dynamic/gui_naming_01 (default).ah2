; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>

global hwnd

if (1) {
; should be NEW (no name 1)
;   BUT!... will auto-default to Gui number 1)
  If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
  }
  mV2GC[["1","Button01"]] := mV2Gui["1"].Add("Button",,"Button01")  ; special case
; should be SAME as previous
  mV2GC[["1","Button02"]] := mV2Gui["1"].Add("Button",,"Button02")
  mV2Gui["1"].Title := "DEFAULT1"
  mV2Gui["1"].Show("x10 y10 w300 h200")
}

if (1) {
h := 2
; should be NEW (default2), using variable
  mV2Gui[h] := NewV2Gui(h)
  hwnd := mV2Gui[h].Hwnd
  mV2GC[[h,"Button03"]] := mV2Gui[h].Add("Button",,"Button03")
; should be SAME as previous
  mV2GC[[h,"Button04"]] := mV2Gui[h].Add("Button",,"Button04")
  mV2Gui[h].Title := "DEFAULT2"
  mV2Gui[h].Show("x400 y10 w300 h200")
}

ShowWindow( Title := "" ) {
w := 400
if (1) {
    h := hwnd
    ; should NOT be new, adjust title and width
    mV2Gui[h].Title := Title
    mV2Gui[h].Show("w" w " NA")
  }
}

if (1) {
; should NOT be new, using default (second) window
  mV2GC[[h,"Button05"]] := mV2Gui[h].Add("Button",,"Button05")
; should be SAME as previous
  mV2GC[[h,"Button06"]] := mV2Gui[h].Add("Button",,"Button06")
}


if (1) {
; should NOT be new - use first window above
  mV2GC[["1","Button07"]] := mV2Gui["1"].Add("Button",,"Button07")
; should NOT be new - use default (second) window
  mV2GC[[h,"Button08"]] := mV2Gui[h].Add("Button",,"Button08")
}


if (1) {
; should be NEW (NEW DEFAULT3)
  mV2Gui["nnGui2"] := NewV2Gui("nnGui2")
; place on default window just created, and show
  mV2GC[["nnGui2","Button09"]] := mV2Gui["nnGui2"].Add("Button",,"Button09")
  mV2Gui["nnGui2"].Title := "DEFAULT3"
  mV2Gui["nnGui2"].Show("x10 y300 w300 h200")
}

if (1) {
; should use first window above
  mV2GC[["1","Button10"]] := mV2Gui["1"].Add("Button",,"Button10")
; should use second window above
  mV2GC[[h,"Button11"]] := mV2Gui[h].Add("Button",,"Button11")
}

if (1) {
; should be NEW (NEW DEFAULT4)
  mV2Gui["nnGui3"] := NewV2Gui("nnGui3")
; place on default window just created, and show
  mV2GC[["nnGui3","Button12"]] := mV2Gui["nnGui3"].Add("Button",,"Button12")
  mV2Gui["nnGui3"].Title := "DEFAULT4"
  mV2Gui["nnGui3"].Show("x400 y300 w300 h200")
}

if (1) {
 ; place on second window (same as h)
  If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
  }
  mV2GC[["2","Button13"]] := mV2Gui["2"].Add("Button",,"Button13")
; place on DEFAULT4
  mV2GC[["nnGui3","Button14"]] := mV2Gui["nnGui3"].Add("Button",,"Button14")
}

ShowWindow( "DEFAULT2 - NEW TITLE !" )