; test keyword conversion, ensure that strings are not affected
Clipboard := """" Trim(Clipboard) """"
Clipboard := "clipboard"
New := "new"
newObject := new class()
New("new argument", "my clipboard", obj := new class(), clipboard)
{

}