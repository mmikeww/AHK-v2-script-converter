Loop Files, %A_ProgramFiles%\*.txt, R  ; Recurse into subfolders.
{
    MsgBox, 4, , Filename = %A_LoopFileFullPath%`n`nContinue?
    IfMsgBox, No
        break
}