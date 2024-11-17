#Persistent
SetTimer, CloseMailWarnings, 250
return

CloseMailWarnings:
WinClose, Microsoft Outlook, A timeout occured while communicating
WinClose, Microsoft Outlook, A connection to the server could not be established
return