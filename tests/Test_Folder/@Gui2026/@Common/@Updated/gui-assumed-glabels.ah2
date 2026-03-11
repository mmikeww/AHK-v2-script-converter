; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
Gui1Pos := A_ScreenHeight // 2 * 0.7

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Button1"]] := mV2Gui["1"].Add("Button",,"Button 1")
mV2GC[["1","Button1"]].OnEvent("Click",ButtonButton1.Bind("Normal"))
mV2GC[["1","Button2"]] := mV2Gui["1"].Add("Button","ys","Button 2")
mV2GC[["1","Button2"]].OnEvent("Click",ButtonButton2.Bind("Normal"))
mV2Gui["1"].Show("y" . Gui1Pos)

mV2Gui["nnGui2"] := NewV2Gui("nnGui2")
mV2GC[["nnGui2","Button3"]] := mV2Gui["nnGui2"].Add("Button",,"Button 3")
mV2GC[["nnGui2","Button3"]].OnEvent("Click",ButtonButton3.Bind("Normal"))
mV2GC[["nnGui2","Button4"]] := mV2Gui["nnGui2"].Add("Button","ys","Button 4")
mV2GC[["nnGui2","Button4"]].OnEvent("Click",ButtonButton4.Bind("Normal"))
mV2GC[["nnGui2","Button5"]] := mV2Gui["nnGui2"].Add("Button","ys","Button 5")
mV2Gui["nnGui2"].Show()
Return

ButtonButton1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
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
MsgBox("Fourth Button Pressed via " A_GuiEvent)
Return
}

;###############  V1toV2 FUNCS  ###############
ButtonButton2(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Second Button Pressed")
Return
}
;##############################################
ButtonButton3(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("Third Button Pressed")
Return
}