Clipboard := "" ; Empty the clipboard
Send, ^c
ClipWait, 2
if ErrorLevel
{
    MsgBox, The attempt to copy text onto the clipboard failed.
    return
}
MsgBox, clipboard = %Clipboard%
return