myGui := Gui()
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Tag.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Test.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Tag1.Bind("Normal"))
ogcButtonTest := myGui.Add("Button", , "Test")
ogcButtonTest.OnEvent("Click", Test1.Bind("Normal"))
myGui.Show()

Goto("Somewhere")
Return

Somewhere:
MsgBox("Test")
Return