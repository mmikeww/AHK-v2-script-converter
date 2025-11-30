var1 := ""  ; Make it blank so that the below will use the current timestamp instead.
var1 += 31, days
MsgBox, %var1%  ; The answer will be the date 31 days from now.

var = %A_Now%
EnvAdd, var, 7, days
FormatTime, var, %var%, ShortDate
MsgBox, %var1%