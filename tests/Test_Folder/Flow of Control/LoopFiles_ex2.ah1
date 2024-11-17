SetBatchLines, -1  ; Make the operation run at maximum speed.
FolderSizeKB := 0
FileSelectFolder, WhichFolder  ; Ask the user to pick a folder.
Loop, Files, %WhichFolder%\*.*, R
    FolderSizeKB += A_LoopFileSizeKB
MsgBox Size of %WhichFolder% is %FolderSizeKB% KB.