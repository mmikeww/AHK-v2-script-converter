myGui := Gui()
ogcComboBoxColorChoice := myGui.Add("ComboBox", "vColorChoice", ["Red", "Green", "Blue", "Black", "White"])
myGui.Title := "WinTitle"
myGui.Show()
oItems := ControlGetItems("ComboBox1", "WinTitle", , , )
loop oItems.length
{
Items .= A_index=1 ? "" : "`n"
Items .= oItems[A_Index] 
}
Loop Parse, Items, "`n"
    MsgBox("Item number " A_Index " is " A_LoopField ".")