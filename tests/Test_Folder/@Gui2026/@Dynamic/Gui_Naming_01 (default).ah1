
global hwnd

if (1) {
; should be NEW (no name 1)
;   BUT!... will auto-default to Gui number 1)
  Gui,Add,Button,,Button01  ; special case
; should be SAME as previous
  Gui,Add,Button,,Button02
  Gui,Show,x10 y10 w300 h200, DEFAULT1
}

if (1) {
h := 2
; should be NEW (default2), using variable
  Gui, % h ":New", +hwndhwnd
  Gui, % h ":Add",Button,,Button03
; should be SAME as previous
  Gui,Add,Button,,Button04
  Gui,Show, x400 y10 w300 h200, DEFAULT2
}

ShowWindow( Title := "" ) {
w := 400
if (1) {
    h := hwnd
    ; should NOT be new, adjust title and width
    Gui, % h ":Show", % "w" w " NA", % Title
  }
}

if (1) {
; should NOT be new, using default (second) window
  Gui, % h ":Add",Button,,Button05
; should be SAME as previous
  Gui,Add,Button,,Button06
}


if (1) {
; should NOT be new - use first window above
  Gui,1:Add,Button,,Button07
; should NOT be new - use default (second) window
  Gui,Add,Button,,Button08
}


if (1) {
; should be NEW (NEW DEFAULT3)
  Gui,New
; place on default window just created, and show
  Gui,Add,Button,,Button09
  Gui,Show,x10 y300 w300 h200, DEFAULT3
}

if (1) {
; should use first window above
  Gui,1:Add,Button,,Button10
; should use second window above
  Gui, % h ":Add",Button,,Button11
}

if (1) {
; should be NEW (NEW DEFAULT4)
  Gui,New
; place on default window just created, and show
  Gui,Add,Button,,Button12
  Gui,Show,x400 y300 w300 h200, DEFAULT4
}

if (1) {
 ; place on second window (same as h)
  Gui,2:Add,Button,,Button13
; place on DEFAULT4
  Gui,Add,Button,,Button14
}

ShowWindow( "DEFAULT2 - NEW TITLE !" )