if (FoundPos := RegExMatch("abcdefg", "f(?<name>g)", &OutputVar)) {
    Text := ""
    Text .= "$0 pos: " FoundPos "`n"
    Text .= "$0 len: " OutputVar.Len "`n"
    Text .= "$1 pos: " OutputVar.Pos["name"] "`n"
    Text .= "$1 len: " OutputVar.Len["name"] "`n"
    MsgBox(Text)
}