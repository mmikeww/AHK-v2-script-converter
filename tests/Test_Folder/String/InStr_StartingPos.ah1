MsgBox % InStr("ababab", "b", , 1) ; Returns 2
MsgBox % InStr("ababab", "b", , 0) ; Returns 6
MsgBox % InStr("ababab", "b", , -1) ; Returns 4
