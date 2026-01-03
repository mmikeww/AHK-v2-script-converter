#Warn Unreachable, Off
Persistent
SetTimer(CloseMailWarnings,250)
return

CloseMailWarnings:
CloseMailWarnings()
return

;###############  V1toV2 FUNCS  ###############
CloseMailWarnings() { ; V1toV2: Lbl->Func
global
WinClose("Microsoft Outlook", "A timeout occured while communicating")
WinClose("Microsoft Outlook", "A connection to the server could not be established")
return
}