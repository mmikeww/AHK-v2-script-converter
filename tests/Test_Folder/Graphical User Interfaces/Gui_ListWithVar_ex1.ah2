MyArr := "a|b|c"
myGui := Gui()
myGui.Add("DDL", "x10", StrSplit(MyArr, "|")) ; V1toV2: Ensure DDL has correct choose value
myGui.Show()