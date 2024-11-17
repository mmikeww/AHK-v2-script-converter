; V1toV2: Removed SetBatchLines, -1  ; Make the operation run at maximum speed.
FolderSize := 0
WhichFolder := DirSelect()  ; Ask the user to pick a folder.
Loop Files, WhichFolder "\*.*", "R"
    FolderSize += A_LoopFileSize
MsgBox("Size of " WhichFolder " is " FolderSize " bytes.")