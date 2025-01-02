var := "hello,world"
if (var = "hello,world")
    MsgBox("var matches")

var := "val"
if (var != "value")
    MsgBox(var)

var := "value"
if (StrCompare(var, "value") >= 0)
    MsgBox(var)

var := "zzz"
if (StrCompare(var, "value") > 0)
    MsgBox(var)

var := 4
if (var > 3)
    MsgBox(var)

var := "hhh"
if (StrCompare(var, "value") < 0)
    MsgBox(var)

var := 1
if (var < 4)
    MsgBox(var)

var := "hhh"
if (StrCompare(var, "value") <= 0)
    MsgBox(var)