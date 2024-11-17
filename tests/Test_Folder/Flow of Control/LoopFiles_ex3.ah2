FileList := ""  ; Initialize to be blank.
Loop Files, "C:\*.*"
    FileList .= A_LoopFileName "`n"
FileList := Sort(FileList, "R")  ; The R option sorts in reverse order. See Sort for other options.
Loop Parse, FileList, "`n"
{
    if (A_LoopField = "")  ; Ignore the blank item at the end of the list.
        continue
    msgResult := MsgBox("File number " A_Index " is " A_LoopField ".  Continue?", "", 4)
    if (msgResult = "No")
        break
}