var1 := ""
var2 := 20040126
EnvSub, var1, %var2%, days
MsgBox, %var1%

var1 := 20990101
var2 := ""
EnvSub, var1, %var2%, days
MsgBox, %var1%

var1 = 20050126
var2 = 20040126
EnvSub, var1, %var2%, days
MsgBox, %var1%