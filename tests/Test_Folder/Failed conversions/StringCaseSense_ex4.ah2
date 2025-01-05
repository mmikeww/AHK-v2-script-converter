A_StringCaseSense := true

var1 := "abc"
var2 := "ABC"

if ((A_StringCaseSense and var1 == var2) or (!A_StringCaseSense and var1 = var2))
    MsgBox("true")