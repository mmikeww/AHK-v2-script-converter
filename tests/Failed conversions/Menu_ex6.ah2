; Menu Example #4
FileMenu := Menu()
FileMenu.Add("Script Icon", MenuHandler)
FileMenu.Add("Suspend Icon", MenuHandler)
FileMenu.Add("Pause Icon", MenuHandler)
FileMenu.SetIcon("Script Icon", A_AhkPath, "2") ; Use the 2nd icon group from the file
FileMenu.SetIcon("Suspend Icon", A_AhkPath, "-206") ; Use icon with resource identifier 206
FileMenu.SetIcon("Pause Icon", A_AhkPath, "-207") ; Use icon with resource identifier 207
MyMenuBar := MenuBar()
MyMenuBar.Add("&File", FileMenu)
myGui := Gui()
myGui.MenuBar := MyMenuBar
ogcButtonExitThisExample := myGui.Add("Button", , "Exit This Example")
ogcButtonExitThisExample.OnEvent("Click", Exit.Bind("Normal"))
myGui.Show()
return

MenuHandler(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{ ; V1toV2: Added bracket
return
} ; V1toV2: Added Bracket before label

Exit(A_GuiEvent, GuiCtrlObj, Info, *)
{ ; V1toV2: Added bracket
ExitApp()




} ; Added bracket in the end