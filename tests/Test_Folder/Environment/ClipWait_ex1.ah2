A_Clipboard := "" ; Empty the clipboard
Send("^c")
Errorlevel := !ClipWait(2)
if ErrorLevel
{
    MsgBox("The attempt to copy text onto the clipboard failed.")
    return
}
MsgBox("clipboard = " A_Clipboard)
return