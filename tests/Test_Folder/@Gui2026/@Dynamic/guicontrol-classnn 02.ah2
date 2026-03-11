; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off

If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
}
mV2GC[["2","btn1"]] := mV2Gui["2"].Add("Button","vbtn1","Hello")
mV2GC[["2","btn2"]] := mV2Gui["2"].Add("Button","vbtn2","Goodbye (clickMe)")
mV2GC[["2","btn2"]].OnEvent("Click",Btn2Lbl.Bind("Normal"))
mV2GC[["2","Group1"]] := mV2Gui["2"].Add("GroupBox","x0 y70 h50 w150 wrap","Group1")
mV2Gui["2"].Show("w200 h125")
fcV2GC("2","Button2").Move(50, 10, 125, 50)

return
Btn2Lbl:
Btn2Lbl()
ExitApp()

;###############  V1toV2 FUNCS  ###############
Btn2Lbl(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
fcV2GC("2","Button1").Visible := false
fcV2GC("2","Button2").Enabled := false
mV2Gui["2"].SetFont("s10 Bold","Verdana")
fcV2GC(A_Gui,"Button3").Text := "GroupBox is actually a `"Button`" Class"
fcV2GC("2","Button3").SetFont("s10 Bold","Verdana")
Sleep(3000)
fcV2GC(A_Gui,"Button2").Text := "See ya!"
fcV2GC("2","Button2").SetFont("s10 Bold","Verdana")
Sleep(1500)
Try mV2Gui[A_Gui].Destroy()
ExitApp()
}