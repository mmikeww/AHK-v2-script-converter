Gui1Pos := A_ScreenHeight // 2 * 0.7

myGui := Gui()
ogcButtonButton1 := myGui.Add("Button", , "Button 1")
ogcButtonButton1.OnEvent("Click", ButtonButton1.Bind("Normal"))
ogcButtonButton2 := myGui.Add("Button", "ys", "Button 2")
ogcButtonButton2.OnEvent("Click", ButtonButton2.Bind("Normal"))
myGui.Show("y" . Gui1Pos)

myGui1 := Gui()
ogcButtonButton3 := myGui1.Add("Button", , "Button 3")
ogcButtonButton3.OnEvent("Click", ButtonButton3.Bind("Normal"))
ogcButtonButton4 := myGui1.Add("Button", "ys", "Button 4")
ogcButtonButton4.OnEvent("Click", ButtonButton4.Bind("Normal"))
ogcButtonButton5 := myGui1.Add("Button", "ys", "Button 5")
myGui1.Show()
Return

ButtonButton1(A_GuiEvent := "", A_GuiControl := "", Info := "", *) {
MsgBox("First Button Pressed")
Return
}

ButtonButton2(A_GuiEvent := "", A_GuiControl := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("Second Button Pressed")
Return
} ; V1toV2: Added Bracket before label

ButtonButton3(A_GuiEvent := "", A_GuiControl := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("Third Button Pressed")
Return
} ; V1toV2: Added bracket before function

ButtonButton4(A_GuiEvent := "", A_GuiControl := "", Info := "", *) {
MsgBox("Fourth Button Pressed via " A_GuiEvent)
Return
}