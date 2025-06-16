; Modified from https://github.com/PayloadSecurity/VxCommunity/blob/master/poc/sandbox_bypass_wmi/notepad.ahk

strCommand := "notepad.exe"
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
objProcess := objWMIService.Get("Win32_Process")
Null := ComObjMissing()
VarSetCapacity(processID, 4, 0)
processIDRef := ComObjParameter(0x4|0x4000, &processID)
errReturn := objProcess.Create(strCommand, Null, ComObjMissing(), processIDRef)
msgbox % errReturn . "`n" . NumGet(processID)