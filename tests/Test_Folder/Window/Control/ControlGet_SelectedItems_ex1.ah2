SelectedItems := ListViewGetContent("Selected", "SysListView321", "WinTitle")
Loop Parse, SelectedItems, "`n"  ; Rows are delimited by linefeeds (`n).
{
    RowNumber := A_Index
    Loop Parse, A_LoopField, A_Tab  ; Fields (columns) in each row are delimited by tabs (A_Tab).
        MsgBox("Row #" RowNumber " Col #" A_Index " is " A_LoopField ".")
}