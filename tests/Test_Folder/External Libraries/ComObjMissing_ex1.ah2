; Modified from https://github.com/PayloadSecurity/VxCommunity/blob/master/poc/sandbox_bypass_wmi/notepad.ahk

strCommand := "notepad.exe"
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
objProcess := objWMIService.Get("Win32_Process")
; V1toV2: Removed Null := ComObjMissing()
processID := Buffer(4, 0) ; V1toV2: if 'processID' is a UTF-16 string, use 'VarSetStrCapacity(&processID, 4)' and replace all instances of 'processID.Ptr' with 'StrPtr(processID)'
processIDRef := ComValue(0x4|0x4000, processID.Ptr)
errReturn := objProcess.Create(strCommand, , , processIDRef) ; V1toV2: Removed ComObjMissing() ; V1toV2: Removed ComObjMissing() variable Null
MsgBox(errReturn . "`n" . NumGet(processID, "UPtr"))