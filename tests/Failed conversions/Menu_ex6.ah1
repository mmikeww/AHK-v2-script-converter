; Menu Example #4
Menu, FileMenu, Add, Script Icon, MenuHandler
Menu, FileMenu, Add, Suspend Icon, MenuHandler
Menu, FileMenu, Add, Pause Icon, MenuHandler
Menu, FileMenu, Icon, Script Icon, %A_AhkPath%, 2 ; Use the 2nd icon group from the file
Menu, FileMenu, Icon, Suspend Icon, %A_AhkPath%, -206 ; Use icon with resource identifier 206
Menu, FileMenu, Icon, Pause Icon, %A_AhkPath%, -207 ; Use icon with resource identifier 207
Menu, MyMenuBar, Add, &File, :FileMenu
Gui, Menu, MyMenuBar
Gui, Add, Button, gExit, Exit This Example
Gui, Show
return

MenuHandler:
return

Exit:
ExitApp