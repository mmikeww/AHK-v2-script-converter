SetBatchLines, -1  ; Make the operation run at maximum speed.
FolderSize := 0
FileSelectFolder, WhichFolder  ; Ask the user to pick a folder.
Loop, %WhichFolder%\*.*, , 1
    FolderSize += A_LoopFileSize
MsgBox Size of %WhichFolder% is %FolderSize% bytes.