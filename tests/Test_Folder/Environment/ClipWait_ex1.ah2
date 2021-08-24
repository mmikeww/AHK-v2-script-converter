A_Clipboard := "" ; Empty the clipboard
Send("^c")
Errorlevel := !ClipWait(2,)
if ErrorLevel
{
    msgResult := MsgBox("The attempt to copy text onto the A_Clipboard failed.")
    return
}
msgResult := MsgBox("A_Clipboard = " . A_Clipboard)
return