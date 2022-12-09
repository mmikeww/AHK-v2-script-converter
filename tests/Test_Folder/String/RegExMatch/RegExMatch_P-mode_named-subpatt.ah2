if (FoundPos := RegExMatch("abcdefg", "f(?<name>g)", &OutputVar)) {
    Text := ""
    Text .= "$0 pos: " FoundPos "`n"
    Text .= "$0 len: " OutputVar.Len "`n"
    Text .= "$1 pos: " OutputVar.Pos["Name"] "`n"
    Text .= "$1 len: " OutputVar.Len["Name"] "`n"
    MsgBox(Text)
}