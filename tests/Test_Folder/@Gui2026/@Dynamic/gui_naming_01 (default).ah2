#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder

global hwnd

if (1) {
; should be NEW (no name 1)
;   BUT!... will auto-default to Gui number 1)
  If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
  }
  mV2GC[["","Button01"]] := mV2Gui[""].Add("Button",,"Button01")  ; special case
; should be SAME as previous
  mV2GC[["","Button02"]] := mV2Gui[""].Add("Button",,"Button02")
  mV2Gui[""].Title := "DEFAULT1"
  mV2Gui[""].Show("x10 y10 w300 h200")
}

if (1) {
h := 2
; should be NEW (default2), using variable
  mV2Gui[h] := NewV2Gui(h,1)
  hwnd := mV2Gui[h].Hwnd
  mV2GC[[h,"Button03"]] := mV2Gui[h].Add("Button",,"Button03")
; should be SAME as previous
  mV2GC[["","Button04"]] := mV2Gui[""].Add("Button",,"Button04")
  mV2Gui[""].Title := "DEFAULT2"
  mV2Gui[""].Show("x400 y10 w300 h200")
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
  mV2GC[["","Button06"]] := mV2Gui[""].Add("Button",,"Button06")
}


if (1) {
; should NOT be new - use first window above
  If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
  }
  mV2GC[["1","Button07"]] := mV2Gui["1"].Add("Button",,"Button07")
; should NOT be new - use default (second) window
  mV2GC[["","Button08"]] := mV2Gui[""].Add("Button",,"Button08")
}


if (1) {
; should be NEW (NEW DEFAULT3)
  mV2Gui[""] := NewV2Gui("",1)
; place on default window just created, and show
  mV2GC[["","Button09"]] := mV2Gui[""].Add("Button",,"Button09")
  mV2Gui[""].Title := "DEFAULT3"
  mV2Gui[""].Show("x10 y300 w300 h200")
}

if (1) {
; should use first window above
  mV2GC[["1","Button10"]] := mV2Gui["1"].Add("Button",,"Button10")
; should use second window above
  mV2GC[[h,"Button11"]] := mV2Gui[h].Add("Button",,"Button11")
}

if (1) {
; should be NEW (NEW DEFAULT4)
  mV2Gui[""] := NewV2Gui("",1)
; place on default window just created, and show
  mV2GC[["","Button12"]] := mV2Gui[""].Add("Button",,"Button12")
  mV2Gui[""].Title := "DEFAULT4"
  mV2Gui[""].Show("x400 y300 w300 h200")
}

if (1) {
 ; place on second window (same as h)
  If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
  }
  mV2GC[["2","Button13"]] := mV2Gui["2"].Add("Button",,"Button13")
; place on DEFAULT4
  mV2GC[["","Button14"]] := mV2Gui[""].Add("Button",,"Button14")
}

ShowWindow( "DEFAULT2 - NEW TITLE !" )