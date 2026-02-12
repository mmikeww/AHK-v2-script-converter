myGui := Gui()
Tab := myGui.Add("Tab3", "Choose2", ["General", "View", "Settings"])
myGui.Title := "Some Window Title"
myGui.Show()
WhichTab := ControlGetIndex("SysTabControl321", "Some Window Title")
MsgBox("Tab #" WhichTab " is active.")