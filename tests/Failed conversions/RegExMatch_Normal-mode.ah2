if (FoundPos := RegExMatch("abcdefg", "f(g)", &OutputVar)) {
    Text := ""
    Text .= "$0: " (OutputVar && OutputVar[0]) "`n"
    Text .= "$1: " OutputVar[1] "`n"
    MsgBox(Text)
}