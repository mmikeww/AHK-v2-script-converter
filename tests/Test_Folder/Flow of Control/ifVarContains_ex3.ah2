var := "33"
if (var ~= "i)(1|3)")  ; Note that it compares the values as strings, not numbers.
    MsgBox("Var contains the digit 1 or 3 (Var could be 1, 3, 10, 21, 23, etc.)")