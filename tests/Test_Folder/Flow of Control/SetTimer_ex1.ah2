Persistent
SetTimer(CloseMailWarnings,250)
return

CloseMailWarnings()
{ ; V1toV2: Added bracket
WinClose("Microsoft Outlook", "A timeout occured while communicating")
WinClose("Microsoft Outlook", "A connection to the server could not be established")
return
} ; V1toV2: Added bracket in the end
