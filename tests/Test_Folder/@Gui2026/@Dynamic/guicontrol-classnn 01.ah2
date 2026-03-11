; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","btn1"]] := mV2Gui["1"].Add("Button","vbtn1","Hello")
mV2GC[["1","btn2"]] := mV2Gui["1"].Add("Button","vbtn2","Goodbye (clickMe)")
mV2GC[["1","btn2"]].OnEvent("Click",Btn2Lbl.Bind("Normal"))
mV2Gui["1"].Show("w200 h100")
fcV2GC("","Button2").Move(50, 10, 125, 50)

return
Btn2Lbl:
Btn2Lbl()
return

;###############  V1toV2 FUNCS  ###############
Btn2Lbl(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
fcV2GC("","Button1").Visible := false
fcV2GC(A_Gui,"Button2").Text := "See ya!"
fcV2GC("","Button2").Enabled := false
mV2Gui["1"].SetFont("s10 Bold","Verdana")
fcV2GC("","Button2").SetFont("s10 Bold","Verdana")
Sleep(1000)
Try mV2Gui[A_Gui].Destroy()
}