#SingleInstance, force
Menu, Tab1, Add, First Tab Item, MenuHandler
Menu, Tab1, Check, First Tab Item
Menu, Tab1, Add, Second Tab Item, MenuHandler
Menu, Tab1, Add, Third Tab Item, MenuHandler

Menu, SubMenu1, Add, First Tab Item, MenuHandler
Menu, SubMenu1, Add, Second Tab Item, MenuHandler
Menu, SubMenu1, Add, Third Tab Item, MenuHandler

Menu, Tab2, Add, SubMenu, :SubMenu1

Menu, SubMenu3, Add, First Tab Item, MenuHandler
Menu, SubMenu3, Add, Second Tab Item, MenuHandler
Menu, SubMenu3, Add, Third Tab Item, MenuHandler

Menu, SubMenu4, Add, First Tab Item, MenuHandler
Menu, SubMenu4, Add, Second Tab Item, MenuHandler
Menu, SubMenu4, Add, Third Tab Item, MenuHandler

Menu, SubMenu5, Add, First Tab Item, MenuHandler
Menu, SubMenu5, Add, Second Tab Item, MenuHandler
Menu, SubMenu5, Add, Third Tab Item, MenuHandler

Menu, SubMenu2, Add, SubMenu 1, :SubMenu3
Menu, SubMenu2, Add, SubMenu 2, :SubMenu4
Menu, SubMenu2, Add, SubMenu 3, :SubMenu5

Menu, Tab2, Add, Double Submenu, :SubMenu2

Menu, Tab3, Add, Colored Option, MenuHandler

Menu, SubMenu6, Add, First Tab Item, MenuHandler
Menu, SubMenu6, Add, Second Tab Item, MenuHandler
Menu, SubMenu6, Add, Third Tab Item, MenuHandler

Menu, Tab3, Add, Colored Submenu, :SubMenu6

Menu, Tab3, Color, Red

Menu, Tab4, Add, Colored Option, MenuHandler

Menu, SubMenu7, Add, First Tab Item, MenuHandler
Menu, SubMenu7, Add, Second Tab Item, MenuHandler
Menu, SubMenu7, Add, Third Tab Item, MenuHandler

Menu, Tab4, Add, Colored Submenu, :SubMenu7

Menu, Tab4, Color, Red, Single

Menu, Tab5, Add, Different Check, MenuHandler
Menu, Tab5, Check, Different Check
Menu, Tab5, Add, Radio Checked, MenuHandler, +Radio
Menu, Tab5, Check, Radio Checked
Menu, Tab5, Add, New Column, MenuHandler, +Break
Menu, Tab5, Add, Separated, MenuHandler, +BarBreak

Menu, Tab6, Add, V1 Icons available at A_AhkPath, MenuHandler
Menu, Tab6, Add
Menu, Tab6, Add, Icon 1, MenuHandler
Menu, Tab6, Icon, Icon 1, %A_AhkPath%, 1
Menu, Tab6, Add, Icon 2, MenuHandler
Menu, Tab6, Icon, Icon 2, %A_AhkPath%, 2
Menu, Tab6, Add, Icon 3, MenuHandler
Menu, Tab6, Icon, Icon 3, %A_AhkPath%, 3
Menu, Tab6, Add, Icon 4, MenuHandler
Menu, Tab6, Icon, Icon 4, %A_AhkPath%, 4
Menu, Tab6, Add, Icon 5, MenuHandler
Menu, Tab6, Icon, Icon 5, %A_AhkPath%, 5

Menu, Tab7, Add, First Tab Item, MenuHandler
Menu, Tab7, Add, Second Tab Item, MenuHandler
Menu, Tab7, Insert, Second Tab Item, Inserted Tab Item, MenuHandler
Menu, Tab7, Add, Deleted Option (Only visible in code), MenuHandler
Menu, Tab7, Delete, Deleted Option (Only visible in code)
Menu, Tab7, Add, Unrenamed Item, MenuHandler
Menu, Tab7, Rename, Unrenamed Item, Renamed Item
Menu, Tab7, Add, Disabled Item, MenuHandler
Menu, Tab7, Disable, Disabled Item

Menu, MyMenuBar, Add, Regular Options, :Tab1
Menu, MyMenuBar, Add, SubMenu Options, :Tab2
Menu, MyMenuBar, Add, Color Options, :Tab3
Menu, MyMenuBar, Add, Color Options (Single), :Tab4
Menu, MyMenuBar, Add, Misc, :Tab7
Menu, MyMenuBar, Add, Format, :Tab5, +Right
Menu, MyMenuBar, Add, Icons, :Tab6

Menu, Tray, Add
Menu, Tray, Add, Custom option in tray, MenuHandler

Menu, Tray, Tip, Menu Conversion Stress Test Tooltip

Gui, Menu, MyMenuBar
Gui, Add, Text,, Menu Convertor Stress Test
Gui, Add, Text,, Contains most menu sub-commands
Gui, Add, Button, gExit, Exit
Gui, Add, Button, gDelete, Delete All
Gui, +Resize
Gui, Show, w640, Menu Convertor Stress Test
Return

MenuHandler:
MsgBox, You selected "%A_ThisMenuItem%".
Return

Delete:
Menu, Tab1, Delete
Menu, Tab2, Delete
Menu, Tab3, Delete
Menu, Tab4, Delete
Menu, Tab5, Delete
Menu, Tab6, Delete
Menu, Tab7, Delete
Return

Exit:
ExitApp