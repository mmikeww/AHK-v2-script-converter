var1 := ""
var2 := 20040126
var1 := DateDiff((var1 != "" ? var1 : A_Now), (var2 != "" ? var2 : A_Now), "days")
MsgBox(var1)

var1 := 20990101
var2 := ""
var1 := DateDiff((var1 != "" ? var1 : A_Now), (var2 != "" ? var2 : A_Now), "days")
MsgBox(var1)

var1 := 20050126
var2 := 20040126
var1 := DateDiff((var1 != "" ? var1 : A_Now), (var2 != "" ? var2 : A_Now), "days")
MsgBox(var1)