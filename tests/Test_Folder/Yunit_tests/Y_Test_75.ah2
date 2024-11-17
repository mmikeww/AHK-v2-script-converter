var := "3.1415"
if isFloat(var)
   FileAppend(var " is float", "*")
else if isInteger(var)
   FileAppend(var " is int", "*")