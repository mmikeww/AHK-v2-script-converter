FileObj := FileOpen("testV2.ahk", "w")

MsgBox(FileObj.Handle "`n" FileObj.Handle)

FileObj.Pos := 2
MsgBox(FileObj.Pos "`n" FileObj.Pos)

MsgBox(FileObj.Pos)