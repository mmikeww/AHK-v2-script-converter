Gui, Add, ComboBox, vColorChoice, Red|Green|Blue|Black|White
Gui, Show,,WinTitle
ControlGet, Items, List,, ComboBox1, WinTitle
Loop, Parse, Items, `n
    MsgBox Item number %A_Index% is %A_LoopField%.