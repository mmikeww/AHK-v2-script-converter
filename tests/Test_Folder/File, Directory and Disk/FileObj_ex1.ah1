FileObj := FileOpen("testV2.ahk", "w")

MsgBox % FileObj.Handle "`n" FileObj.__Handle

FileObj.Position(2)
MsgBox % FileObj.Pos "`n" FileObj.Position

MsgBox % FileObj.Tell()