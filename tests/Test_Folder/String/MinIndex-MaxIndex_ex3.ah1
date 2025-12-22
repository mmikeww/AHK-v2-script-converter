
; var assignment of literal array
arr := ["a","b"]
elemCount := arr.MaxIndex()
msgbox % elemCount ; 2

; direct literal array
msgbox % ["e1", "e2", "e3"].MaxIndex() ; 3

; via StrSplit
str := "a`tb`tc`td"
msgbox % StrSplit(str, A_Tab).MaxIndex() ; 4

; chained assignments - incorrect conversion
all:=["a","l","l"],SnakeBody:=[1,2,3,4,5]
Total:=all.Length,Tick:=A_TickCount,maxLen:=SnakeBody.MaxIndex(),var:="whatever"
msgbox % maxLen ; 5