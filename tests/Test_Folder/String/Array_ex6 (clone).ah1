strings =
(
One
Two
Three
)
arr1 := StrSplit(strings, "`n")
arr2 := arr1.clone() ; detect arr2 is array
arr2.Remove(2)
MsgBox % arr2[2] ; Three