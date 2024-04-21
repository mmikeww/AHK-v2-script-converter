#SingleInstance force
Tab1 := Menu()
Tab1.Add("First Tab Item", MenuHandler)
Tab1.Check("First Tab Item")
Tab1.Add("Second Tab Item", MenuHandler)
Tab1.Add("Third Tab Item", MenuHandler)

SubMenu1 := Menu()
SubMenu1.Add("First Tab Item", MenuHandler)
SubMenu1.Add("Second Tab Item", MenuHandler)
SubMenu1.Add("Third Tab Item", MenuHandler)

Tab2 := Menu()
Tab2.Add("SubMenu", SubMenu1)

SubMenu3 := Menu()
SubMenu3.Add("First Tab Item", MenuHandler)
SubMenu3.Add("Second Tab Item", MenuHandler)
SubMenu3.Add("Third Tab Item", MenuHandler)

SubMenu4 := Menu()
SubMenu4.Add("First Tab Item", MenuHandler)
SubMenu4.Add("Second Tab Item", MenuHandler)
SubMenu4.Add("Third Tab Item", MenuHandler)

SubMenu5 := Menu()
SubMenu5.Add("First Tab Item", MenuHandler)
SubMenu5.Add("Second Tab Item", MenuHandler)
SubMenu5.Add("Third Tab Item", MenuHandler)

SubMenu2 := Menu()
SubMenu2.Add("SubMenu 1", SubMenu3)
SubMenu2.Add("SubMenu 2", SubMenu4)
SubMenu2.Add("SubMenu 3", SubMenu5)

Tab2.Add("Double Submenu", SubMenu2)

Tab3 := Menu()
Tab3.Add("Colored Option", MenuHandler)

SubMenu6 := Menu()
SubMenu6.Add("First Tab Item", MenuHandler)
SubMenu6.Add("Second Tab Item", MenuHandler)
SubMenu6.Add("Third Tab Item", MenuHandler)

Tab3.Add("Colored Submenu", SubMenu6)

Tab3.SetColor("Red")

Tab4 := Menu()
Tab4.Add("Colored Option", MenuHandler)

SubMenu7 := Menu()
SubMenu7.Add("First Tab Item", MenuHandler)
SubMenu7.Add("Second Tab Item", MenuHandler)
SubMenu7.Add("Third Tab Item", MenuHandler)

Tab4.Add("Colored Submenu", SubMenu7)

Tab4.SetColor("Red", 0)

Tab5 := Menu()
Tab5.Add("Different Check", MenuHandler)
Tab5.Check("Different Check")
Tab5.Add("Radio Checked", MenuHandler, "+Radio")
Tab5.Check("Radio Checked")
Tab5.Add("New Column", MenuHandler, "+Break")
Tab5.Add("Separated", MenuHandler, "+BarBreak")

Tab6 := Menu()
Tab6.Add("V1 Icons available at A_AhkPath", MenuHandler)
Tab6.Add()
Tab6.Add("Icon 1", MenuHandler)
Tab6.SetIcon("Icon 1", A_AhkPath, "1")
Tab6.Add("Icon 2", MenuHandler)
Tab6.SetIcon("Icon 2", A_AhkPath, "2")
Tab6.Add("Icon 3", MenuHandler)
Tab6.SetIcon("Icon 3", A_AhkPath, "3")
Tab6.Add("Icon 4", MenuHandler)
Tab6.SetIcon("Icon 4", A_AhkPath, "4")
Tab6.Add("Icon 5", MenuHandler)
Tab6.SetIcon("Icon 5", A_AhkPath, "5")

Tab7 := Menu()
Tab7.Add("First Tab Item", MenuHandler)
Tab7.Add("Second Tab Item", MenuHandler)
Tab7.Insert("Second Tab Item", "Inserted Tab Item", MenuHandler)
Tab7.Add("Deleted Option (Only visible in code)", MenuHandler)
Tab7.Delete("Deleted Option (Only visible in code)")
Tab7.Add("Unrenamed Item", MenuHandler)
Tab7.Rename("Unrenamed Item", "Renamed Item")
Tab7.Add("Disabled Item", MenuHandler)
Tab7.Disable("Disabled Item")

MyMenuBar := MenuBar()
MyMenuBar.Add("Regular Options", Tab1)
MyMenuBar.Add("SubMenu Options", Tab2)
MyMenuBar.Add("Color Options", Tab3)
MyMenuBar.Add("Color Options (Single)", Tab4)
MyMenuBar.Add("Misc", Tab7)
MyMenuBar.Add("Format", Tab5, "+Right")
MyMenuBar.Add("Icons", Tab6)

Tray:= A_TrayMenu
Tray.Add()
Tray.Add("Custom option in tray", MenuHandler)

A_IconTip := "Menu Conversion Stress Test Tooltip"

myGui := Gui()
myGui.MenuBar := MyMenuBar
myGui.Add("Text", , "Menu Convertor Stress Test")
myGui.Add("Text", , "Contains most menu sub-commands")
ogcButtonExit := myGui.Add("Button", , "Exit")
ogcButtonExit.OnEvent("Click", Exit.Bind("Normal"))
ogcButtonDeleteAll := myGui.Add("Button", , "Delete All")
ogcButtonDeleteAll.OnEvent("Click", Delete.Bind("Normal"))
myGui.Opt("+Resize")
myGui.Title := "Menu Convertor Stress Test"
myGui.Show("w640")
Return

MenuHandler(ItemName, ItemPos, MyMenu)
{ ; V1toV2: Added bracket
MsgBox("You selected `"" ItemName "`".")
Return
} ; V1toV2: Added Bracket before label

Delete(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
Tab1.Delete()
Tab2.Delete()
Tab3.Delete()
Tab4.Delete()
Tab5.Delete()
Tab6.Delete()
Tab7.Delete()
Return
} ; V1toV2: Added bracket before function

Exit(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
ExitApp()








































} ; Added bracket in the end
