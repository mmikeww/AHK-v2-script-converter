; test keyword conversion, ensure that strings are not affected
A_Clipboard := "`"" Trim(A_Clipboard) "`""
A_Clipboard := "clipboard"
New := "new"
newObject := class()
New("new argument", "my clipboard", obj := class(), A_Clipboard)
{

}