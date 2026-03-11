; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","ColorChoice"]] := mV2Gui["1"].Add("ComboBox","vColorChoice",["Red","Green","Blue","Black","White"])
mV2Gui["1"].Title := "WinTitle"
mV2Gui["1"].Show()
oItems := ControlGetItems("ComboBox1", "WinTitle", , , )
loop oItems.length
{
    Items .= A_index=1 ? "" : "`n"
    Items .= oItems[A_Index] 
}
Loop Parse, Items, "`n"
    MsgBox("Item number " A_Index " is " A_LoopField ".")