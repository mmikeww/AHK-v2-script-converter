if (FoundPos := RegExMatch("abcdefg", "P)f(g)", OutputVar)) {
    Text := ""
    Text .= "$0 pos: " FoundPos "`n"
    Text .= "$0 len: " OutputVar "`n"
    Text .= "$1 pos: " OutputVarPos1 "`n"
    Text .= "$1 len: " OutputVarLen1 "`n"
    MsgBox % Text
}