Persistent
SetTimer(CloseMailWarnings,250)
return

CloseMailWarnings()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
WinClose("Microsoft Outlook", "A timeout occured while communicating")
WinClose("Microsoft Outlook", "A connection to the server could not be established")
return
} ; V1toV2: Added bracket in the end