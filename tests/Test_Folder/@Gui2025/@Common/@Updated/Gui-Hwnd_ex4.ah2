myGui := Gui()
myGui.Add("Text", , "Gui 1`nNormal")
v1 := myGui.Hwnd
myGui.Show("w100 h100 y0")
myGui2 := Gui(), v2 := myGui2.Hwnd
myGui2.Add("Text", , "Gui 2`nNew")
myGui2.Show("w100 h100 y150")
g2 := Gui(), v3 := g2.Hwnd
g2.Add("Text", , "Gui 3`nName:New")
g2.Show("w100 h100 y300")
g3 := Gui(), v4 := g3.Hwnd
g3.Add("Text", , "Gui 4`nName: New")
g3.Show("w100 h100 y450")
Return

^l::MsgBox(v1 "`n" v2 "`n" v3 "`n" v4)