MyArr := "a|b|c"
myGui := Gui()
myGui.Add("DDL", "x10", StrSplit(MyArr, "|")) ; V1toV2: Check that this DDL has the correct choose value
myGui.Show()