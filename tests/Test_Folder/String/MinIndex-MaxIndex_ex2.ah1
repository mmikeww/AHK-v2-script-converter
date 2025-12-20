
; var assignment of literal array
arr := ["a","b"]
elemCount := arr.MaxIndex()
msgbox % elemCount ; 2

; direct literal array
msgbox % ["e1", "e2", "e3"].MaxIndex() ; 3

; var assignment via reference
fileListStr		:= "File List String"
listValid		:= filterPDF(fileListStr, pdfFilesOnly)
pdfFileCount	:= pdfFilesOnly.MaxIndex()
msgbox % pdfFileCount ; 4

; via StrSplit
str := "a`tb`tc`td`te"
msgbox % StrSplit(str, A_Tab).MaxIndex() ; 5

; chained assignments - incorrect conversion
all:=["a","l","l"],SnakeBody:=[1,2,3,4,5,6]
Total:=all.Length,Tick:=A_TickCount,maxLen:=SnakeBody.MaxIndex(),var:="whatever"
msgbox % maxLen ; 6

filterPDF(str, ByRef outList) {
  outList := ["File1","File2","File3","File4"]
}