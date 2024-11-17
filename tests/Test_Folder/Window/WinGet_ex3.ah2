oActiveControlList := WinGetControls("A",,,)
For v in oActiveControlList
{
   ActiveControlList .= A_index=1 ? v : "`r`n" v
}
Loop Parse, ActiveControlList, "`n"
{
    msgResult := MsgBox("Control #" A_Index " is `"" A_LoopField "`". Continue?", "", 4)
    if (msgResult = "No")
        break
}