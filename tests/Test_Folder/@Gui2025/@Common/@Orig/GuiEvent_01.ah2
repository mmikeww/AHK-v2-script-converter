; missing label/func - should NOT add event
myGui := Gui()
ogcButtonOrder1234 := myGui.Add("Button", "ym", "Order 1, 2, 3, 4")
ogcButtonOrder1234.OnEvent("Click", Order123.Bind("Normal"))
myGui.Show("w200 h100")