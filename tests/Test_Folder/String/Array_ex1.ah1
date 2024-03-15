arr := ["1","2","3"]

arr.Insert("My Value")
arr.Insert(2, "Val 1", "Val 2", "Val 3", "Val 4", "Val 5")

arr.Remove()
arr.Remove(5)
arr.Remove(4,6)

MsgBox % arr.length()
MsgBox % "1: " arr[1] "`n2: " arr[2] "`n3: " arr[3] "`n4: " arr[4]