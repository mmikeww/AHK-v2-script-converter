
MsgBox % "A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]"

Gui 1:Add, Edit,vE1,Edit 1  ; add to gui 1
Gui 1:Show, x200 w250 h100

Gui 2:Add, Edit,vE2,Edit 2  ; add to gui 2
Gui 2:Show, x525 w250 h100

Gui Submit, nohide          ; update vars for gui 1 only (A_DefaultGui := 1)
MsgBox % "A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]"

Gui, 1:Default
Gui add, Edit,vE3,Edit 3    ; add to gui 1 (A_DefaultGui := 1)

Gui Submit, nohide          ; update vars for gui 1 only (A_DefaultGui := 1)
MsgBox % "A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]"

Gui, Default                ; A_DefaultGui := 1 (no change)
Gui add, Edit,vE4,Edit 4    ; add to gui 1 (A_DefaultGui := 1)

Gui Submit, nohide          ; update vars for gui 1 only (A_DefaultGui := 1)
MsgBox % "A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]"

; NOTE: Edit 5 is incorrectly added to gui 1 during conversion, but to gui 2 at execution (correctly)
guiName := "2"
Gui, %guiName%:Default      ; A_DefaultGui := 2
Gui add, Edit,vE5,Edit 5    ; add to gui 2 (A_DefaultGui := 2)

Gui Submit, nohide          ; update vars for gui 2 only (A_DefaultGui := 2)
MsgBox % "A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]"