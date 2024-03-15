arr := ["1","2","3"]

arr.Push("My Value")
arr.InsertAt(2, "Val 1", "Val 2", "Val 3", "Val 4", "Val 5")

arr.Pop()
arr.RemoveAt(5)
arr.RemoveAt(4, 6 - 4 + 1)

MsgBox(arr.Length)
MsgBox("1: " arr[1] "`n2: " arr[2] "`n3: " arr[3] "`n4: " arr[4])