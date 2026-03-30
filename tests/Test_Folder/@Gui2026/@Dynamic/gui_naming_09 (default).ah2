#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars

MsgBox("A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]")

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","E1"]] := mV2Gui["1"].Add("Edit","vE1","Edit 1")  ; add to gui 1
mV2Gui["1"].Show("x200 w250 h100")

If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
}
mV2GC[["2","E2"]] := mV2Gui["2"].Add("Edit","vE2","Edit 2")  ; add to gui 2
mV2Gui["2"].Show("x525 w250 h100")

V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)          ; update vars for gui 1 only (A_DefaultGui := 1)
MsgBox("A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]")

SetDefaultGui("1")
mV2GC[["","E3"]] := mV2Gui[""].add("Edit","vE3","Edit 3")    ; add to gui 1 (A_DefaultGui := 1)

V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)          ; update vars for gui 1 only (A_DefaultGui := 1)
MsgBox("A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]")

SetDefaultGui("")                ; A_DefaultGui := 1 (no change)
mV2GC[["","E4"]] := mV2Gui[""].add("Edit","vE4","Edit 4")    ; add to gui 1 (A_DefaultGui := 1)

V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)          ; update vars for gui 1 only (A_DefaultGui := 1)
MsgBox("A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]")

; NOTE: Edit 5 is incorrectly added to gui 1 during conversion, but to gui 2 at execution (correctly)
guiName := "2"
SetDefaultGui(guiName)      ; A_DefaultGui := 2
mV2GC[["","E5"]] := mV2Gui[""].add("Edit","vE5","Edit 5")    ; add to gui 2 (A_DefaultGui := 2)

V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)          ; update vars for gui 2 only (A_DefaultGui := 2)
MsgBox("A_DefaultGui= " A_DefaultGui "`n[" E1 "]`n[" E2 "]`n[" E3 "]`n[" E4 "]`n[" E5 "]")

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    E1 := ""
    E2 := ""
    E3 := ""
    E4 := ""
    E5 := ""
}