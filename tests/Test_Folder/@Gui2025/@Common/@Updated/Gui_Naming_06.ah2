#Warn Unreachable, Off

delay := 1000

g1 := Gui()
ogcButtonB1 := g1.Add("Button", , "B1")
g1.Show("w500 h500")

Sleep(delay)
myGui := Gui()
myGui.OnEvent("Close", guiClose)
ogcButtonB2 := myGui.Add("Button", , "B2")
myGui.Title := "B2"
myGui.Show("w400 h400")

Sleep(delay)
myGui2 := Gui()
myGui2.OnEvent("Close", guiClose)
ogcButtonB3 := myGui2.Add("Button", , "B3")
myGui2.Title := "B3"
myGui2.Show("w300 h300")

Sleep(delay)
ogcButtonB4 := myGui2.Add("Button", , "B4")
myGui2.Title := "B4"
myGui2.Show("w200 h200")

return
guiClose:
guiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
guiClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("closing")
ExitApp()
}