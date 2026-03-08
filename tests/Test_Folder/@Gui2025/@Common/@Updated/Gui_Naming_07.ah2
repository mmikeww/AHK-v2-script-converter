#Warn Unreachable, Off
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
ogcButtonB1 := myGui.Add("Button", , "B1")
ogcButtonB2 := myGui.Add("Button", , "B2")
myGui.Title := "1"
myGui.Show("w400 h400")

oGui2 := Gui()
ogcButtonB3 := oGui2.Add("Button", , "B3")
oGui2.Title := "2"
oGui2.Show("w300 h300")
ogcButtonB4 := myGui.Add("Button", , "B4")

myGui2 := Gui()
myGui2.OnEvent("Close", GuiClose)
ogcButtonB5 := myGui2.Add("Button", , "B5")
myGui2.Title := "B5"
myGui2.Show("w200 h200")

ogcButtonB6 := myGui.Add("Button", , "B6")

oGui3 := Gui()
ogcButtonB7 := oGui3.Add("Button", , "B7")
oGui3.Title := "3"
oGui3.Show("w75 h75")
ogcButtonB8 := myGui2.Add("Button", , "B8")
oGui3.Title := "3"
oGui3.Show("w200")

return
GuiClose:
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("closing")
ExitApp()
}