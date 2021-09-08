A_Clipboard := "" ; Empty the clipboard
Send("^c")
Errorlevel := !ClipWait(2)
if ErrorLevel
{
    MsgBox("The attempt to copy text onto the A_Clipboard failed.")
    return
}
MsgBox("A_Clipboard = " A_Clipboard)
return