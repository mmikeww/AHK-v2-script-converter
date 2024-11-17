var := "3.1415"
if !(var >= 0.0 && var <= 1.0)
   FileAppend(var " not between 0.0 and 1.0", "*")
else if !(var >= 1 && var <= 4)
   FileAppend(var " not between 1 and 4", "*")