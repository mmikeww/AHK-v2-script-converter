var = hello,world
IfEqual, var, hello,world
    MsgBox, var matches

var = val
IfNotEqual, var, value
    MsgBox, %var%

var := "helloooo"
IfNotEqual, var
   MsgBox, %var%

var = value
IfGreaterOrEqual, var, value
    MsgBox, %var%

var = zzz
IfGreater, var, value
    MsgBox, %var%

var := 4
IfGreater, var, 3
    MsgBox, %var%

var = hhh
IfLess, var, value
    MsgBox, %var%

var := 1
IfLess, var, 4
    MsgBox, %var%

var = hhh
IfLessOrEqual, var, value
    MsgBox, %var%