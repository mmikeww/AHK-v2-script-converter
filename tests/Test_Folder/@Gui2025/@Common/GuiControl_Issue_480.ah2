; https://github.com/mmikeww/AHK-v2-script-converter/issues/480

myGui := Gui()
V2TabCtrl := ogcTab1 := myGui.Add("Tab", "vTab1 w200 h100", ["A", "B", "C"])
V2TabCtrl.UseTab(1)
myGui.Add("Text", , "I am Tab A !")
V2TabCtrl.UseTab(2)
myGui.Add("Text", , "I am Tab B !")
V2TabCtrl.UseTab(3)
myGui.Add("Text", , "I am Tab C !")

V2TabCtrl := ogcTab2 := myGui.Add("Tab", "vTab2 x10 y110 w200 h100", ["D", "E", "F"])
V2TabCtrl.UseTab(1)
myGui.Add("Text", , "I am Tab D !")
V2TabCtrl.UseTab(2)
myGui.Add("Text", , "I am Tab E !")
V2TabCtrl.UseTab(3)
myGui.Add("Text", , "I am Tab F !")
myGui.Show("w220 h220")

TabB:= 2
ogcTab1.Choose(TabB)	; tab B
ogcTab2.Choose(3)		; tab F