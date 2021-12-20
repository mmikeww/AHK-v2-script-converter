if (FoundPos := RegExMatch("abcdefg", "f(g)", &OutputVar)) {
    Text := ""
    Text .= "$0 pos: " FoundPos "`n"
    Text .= "$0 len: " OutputVar.Len "`n"
    Text .= "$1 pos: " OutputVar.Pos[1] "`n"
    Text .= "$1 len: " OutputVar.Len[1] "`n"
    MsgBox(Text)
}