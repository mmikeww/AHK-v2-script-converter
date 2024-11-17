var := A_Now
var := DateAdd(var, 7, "days")
var := FormatTime(var, "ShortDate")
FileAppend(var, "*")