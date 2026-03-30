#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
Gui1Pos := A_ScreenHeight // 2 * 0.7

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Button1"]] := mV2Gui[""].Add("Button",,"Button 1")
mV2GC[["","Button1"]].OnEvent("Click",ButtonButton1.Bind("Normal"))
mV2GC[["","Button2"]] := mV2Gui[""].Add("Button","ys","Button 2")
mV2GC[["","Button2"]].OnEvent("Click",ButtonButton2.Bind("Normal"))
mV2Gui[""].Show("y" . Gui1Pos)

mV2Gui[""] := NewV2Gui("",1)
mV2GC[["","Button3"]] := mV2Gui[""].Add("Button",,"Button 3")
mV2GC[["","Button3"]].OnEvent("Click",ButtonButton3.Bind("Normal"))
mV2GC[["","Button4"]] := mV2Gui[""].Add("Button","ys","Button 4")
mV2GC[["","Button4"]].OnEvent("Click",ButtonButton4.Bind("Normal"))
mV2GC[["","Button5"]] := mV2Gui[""].Add("Button","ys","Button 5")
mV2Gui[""].Show()
Return

ButtonButton1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("First Button Pressed")
Return
}

ButtonButton2:
ButtonButton2()
Return

ButtonButton3:
ButtonButton3()
Return

ButtonButton4(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Fourth Button Pressed via " A_GuiEvent)
Return
}

;###############  V1toV2 FUNCS  ###############
ButtonButton2(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Second Button Pressed")
Return
}
;##############################################
ButtonButton3(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("Third Button Pressed")
Return
}