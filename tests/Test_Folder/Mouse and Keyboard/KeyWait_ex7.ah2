~RControl::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
if (A_PriorHotkey != "~RControl" or A_TimeSincePriorHotkey > 400)
{
    ; Too much time between presses, so this isn't a double-press.
    KeyWait("RControl")
    return
}
MsgBox("You double-pressed the right control key.")
return
} ; V1toV2: Added bracket in the end