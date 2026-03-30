#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","btn1"]] := mV2Gui[""].Add("Button","vbtn1","Hello")
mV2GC[["","btn2"]] := mV2Gui[""].Add("Button","vbtn2","Goodbye (clickMe)")
mV2GC[["","btn2"]].OnEvent("Click",Btn2Lbl.Bind("Normal"))
mV2Gui[""].Show("w200 h100")
fcV2GC("","Button2").Move(50, 10, 125, 50)

return
Btn2Lbl:
Btn2Lbl()
return

;###############  V1toV2 FUNCS  ###############
Btn2Lbl(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
fcV2GC("","Button1").Visible := false
fcV2GC(A_Gui,"Button2").Text := "See ya!"
fcV2GC("","Button2").Enabled := false
mV2Gui[""].SetFont("s10 Bold","Verdana")
fcV2GC("","Button2").SetFont("s10 Bold","Verdana")
Sleep(1000)
DestroyGui(A_Gui)
}