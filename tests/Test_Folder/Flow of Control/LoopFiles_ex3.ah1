FileList := ""  ; Initialize to be blank.
Loop, C:\*.*
    FileList .= A_LoopFileName "`n"
Sort, FileList, R  ; The R option sorts in reverse order. See Sort for other options.
Loop, parse, FileList, `n
{
    if (A_LoopField = "")  ; Ignore the blank item at the end of the list.
        continue
    MsgBox, 4,, File number %A_Index% is %A_LoopField%.  Continue?
    IfMsgBox, No
        break
}