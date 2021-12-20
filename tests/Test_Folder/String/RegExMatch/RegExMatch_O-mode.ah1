if (FoundPos := RegExMatch("abcdefg", "O)f(?<Name>(*MARK:Mark)g)", OutputVar)) {
    Text := ""
    Text .= OutputVar.Mark() "`n"
    Text .= OutputVar.Count() "`n"
    Text .= OutputVar.Name(1) "`n"
    Text .= OutputVar.Value(1) "`n"
    Text .= OutputVar.Value("Name") "`n"
    Text .= OutputVar[1] "`n"
    Text .= OutputVar["Name"] "`n"
    Text .= OutputVar.1 "`n"
    Text .= OutputVar.Name "`n"
    MsgBox % Text
}