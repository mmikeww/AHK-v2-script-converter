; https://github.com/mmikeww/AHK-v2-script-converter/issues/480

Gui, Add, Tab, vTab1 w200 h100, A|B|C
Gui, Tab, 1
Gui, Add, Text,, I am Tab A !
Gui, Tab, 2
Gui, Add, Text,, I am Tab B !
Gui, Tab, 3
Gui, Add, Text,, I am Tab C !

Gui, Add, Tab, vTab2 x10 y110 w200 h100, D|E|F
Gui, Tab, 1
Gui, Add, Text,, I am Tab D !
Gui, Tab, 2
Gui, Add, Text,, I am Tab E !
Gui, Tab, 3
Gui, Add, Text,, I am Tab F !
Gui, Show, w220 h220

TabB= 2
GuiControl, Choose, Tab1, %TabB%	; tab B
GuiControl, Choose, Tab2, 3		; tab F