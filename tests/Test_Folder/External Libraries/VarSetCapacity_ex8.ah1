a := 0
Loop % VarSetCapacity(var,16,0)//4
  a += 1
MsgBox % "Var's capacity of 16 fits {" a "} 4-byte variables"
