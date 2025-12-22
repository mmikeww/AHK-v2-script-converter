
; var assignment of literal array
arr := ["a","b"]
elemCount := arr.Length ; V1toV2: Verify V2 Length value = V1 MaxIndex
MsgBox(elemCount) ; 2

; direct literal array
MsgBox(["e1", "e2", "e3"].Length) ; 3

; via StrSplit
str := "a`tb`tc`td"
MsgBox(StrSplit(str, A_Tab).Length) ; 4

; chained assignments - incorrect conversion
all:=["a","l","l"],SnakeBody:=[1,2,3,4,5]
Total:=all.Length,Tick:=A_TickCount,maxLen:=SnakeBody.Length,var:="whatever" ; V1toV2: Verify V2 Length value = V1 MaxIndex
MsgBox(maxLen) ; 5