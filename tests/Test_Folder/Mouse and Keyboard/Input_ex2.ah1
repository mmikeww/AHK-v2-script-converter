CtrlC := Chr(3) ; Store the character for Ctrl-C in the CtrlC var.
Input, OutputVar, L1 M
if (OutputVar = CtrlC)
    MsgBox, You pressed Control-C.
ExitApp