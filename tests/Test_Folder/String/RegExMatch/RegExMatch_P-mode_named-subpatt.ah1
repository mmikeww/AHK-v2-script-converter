if (FoundPos := RegExMatch("abcdefg", "P)f(?<name>g)", OutputVar)) {
    Text := ""
    Text .= "$0 pos: " FoundPos "`n"
    Text .= "$0 len: " OutputVar "`n"
    Text .= "$1 pos: " OutputVarPosName "`n"
    Text .= "$1 len: " OutputVarLenName "`n"
    MsgBox % Text
}