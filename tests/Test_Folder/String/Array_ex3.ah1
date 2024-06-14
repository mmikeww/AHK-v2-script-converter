arr := ["1","2","3"]

Var2 := 2
Var4 := 4
Var5 := 5
Var6 := 6
Value2 = Val 2

arr.Insert("My Value")
arr.Insert(Var2, "Val 1", Value2, "Val 3", "Val 4", "Val 5")

arr.Remove()
arr.Remove(Var5)
arr.Remove(Var4,Var6)

MsgBox % arr.length()
MsgBox % "1: " arr[1] "`n2: " arr[2] "`n3: " arr[3] "`n4: " arr[4]