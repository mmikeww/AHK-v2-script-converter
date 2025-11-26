var1 := ""  ; Make it blank so that the below will use the current timestamp instead.
var1 := DateAdd((var1 != "" ? var1 : A_Now), 31, 'days')
MsgBox(var1)  ; The answer will be the date 31 days from now.

var := A_Now
var := DateAdd((var != "" ? var : A_Now), 7, "days")
var := FormatTime(var, "ShortDate")
MsgBox(var1)