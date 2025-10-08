#Persistent
MsgBox copy something to the clipboard
return

OnClipboardChange:
MsgBox % "clipboard changed`n" . A_EventInfo
Return