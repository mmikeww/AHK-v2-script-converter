folder := DirSelect(, 3, "Pick a drive to analyze:")
if not folder
    return
list := DriveGetList()
cap := DriveGetCapacity(folder)
free := DriveGetSpaceFree(folder)
fs := DriveGetFileSystem(folder)
label := DriveGetLabel(folder)
serial := DriveGetSerial(folder)
type2 := DriveGetType(folder)
status := DriveGetStatus(folder)
MsgBox("All Drives: " list "`nSelected Drive: " folder "`nDrive Type: " type2 "`nStatus: " status "`nCapacity: " cap " M`nFree Space: " free " M`nFilesystem: " fs "`nVolume Label: " label "`nSerial Number: " serial)