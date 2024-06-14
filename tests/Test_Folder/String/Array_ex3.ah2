arr := ["1","2","3"]

Var2 := 2
Var4 := 4
Var5 := 5
Var6 := 6
Value2 := "Val 2"

arr.Push("My Value")
arr.InsertAt(Var2, "Val 1", Value2, "Val 3", "Val 4", "Val 5")

arr.Pop()
arr.RemoveAt(Var5)
arr.RemoveAt(Var4, Var6 - Var4 + 1)

MsgBox(arr.Length)
MsgBox("1: " arr[1] "`n2: " arr[2] "`n3: " arr[3] "`n4: " arr[4])