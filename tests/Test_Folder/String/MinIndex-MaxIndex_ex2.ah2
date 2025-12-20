
; var assignment of literal array
arr := ["a","b"]
elemCount := ((arr.Length != 0) ? arr.Length : 0)
MsgBox(elemCount) ; 2

; direct literal array
MsgBox(((["e1", "e2", "e3"].Length != 0) ? ["e1", "e2", "e3"].Length : 0)) ; 3

; var assignment via reference
fileListStr		:= "File List String"
listValid		:= filterPDF(fileListStr, &pdfFilesOnly)
pdfFileCount	:= ((pdfFilesOnly.Length != 0) ? pdfFilesOnly.Length : 0)
MsgBox(pdfFileCount) ; 4

; via StrSplit
str := "a`tb`tc`td`te"
MsgBox(((StrSplit(str, A_Tab).Length != 0) ? StrSplit(str, A_Tab).Length : 0)) ; 5

; chained assignments - incorrect conversion
all:=["a","l","l"],SnakeBody:=[1,2,3,4,5,6]
Total:=all.Length,Tick:=A_TickCount,maxLen:=((SnakeBody.Length != 0) ? SnakeBody.Length : 0),var:="whatever"
MsgBox(maxLen) ; 6

filterPDF(str, &outList) {
  outList := ["File1","File2","File3","File4"]
}