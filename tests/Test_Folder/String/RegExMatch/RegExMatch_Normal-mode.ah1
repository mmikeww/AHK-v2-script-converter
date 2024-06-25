if (FoundPos := RegExMatch("abcdefg", "f(g)", OutputVar)) {
    Text := ""
    Text .= "$0: " OutputVar "`n"
    Text .= "$1: " OutputVar1 "`n"
    MsgBox % Text
}