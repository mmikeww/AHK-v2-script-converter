var := "boy"
if ((StrCompare(var, "blue") >= 0) && (StrCompare(var, "red") <= 0))
   FileAppend(var " is alphabetically between 'blue' and 'red'", "*")