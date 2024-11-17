Loop Files, A_ProgramFiles "\*.txt", "R"  ; Recurse into subfolders.
{
    msgResult := MsgBox("Filename = " A_LoopFilePath "`n`nContinue?", "", 4)
    if (msgResult = "No")
        break
}