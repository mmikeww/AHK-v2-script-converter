~RControl::
if (A_PriorHotkey != "~RControl" or A_TimeSincePriorHotkey > 400)
{
    ; Too much time between presses, so this isn't a double-press.
    KeyWait, RControl
    return
}
MsgBox You double-pressed the right control key.
return