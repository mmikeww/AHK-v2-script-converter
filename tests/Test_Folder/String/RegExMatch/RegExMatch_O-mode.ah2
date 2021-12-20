if (FoundPos := RegExMatch("abcdefg", "f(?<Name>(*MARK:Mark)g)", &OutputVar)) {
    Text := ""
    Text .= OutputVar.Mark "`n"
    Text .= OutputVar.Count "`n"
    Text .= OutputVar.Name(1) "`n"
    Text .= OutputVar[1] "`n"
    Text .= OutputVar["Name"] "`n"
    Text .= OutputVar[1] "`n"
    Text .= OutputVar["Name"] "`n"
    Text .= OutputVar.1 "`n"
    Text .= OutputVar["Name"] "`n"
    MsgBox(Text)
}