
; avoid "Invalid Index" errors - issue #428

ColArr := []
Loop, 3
  ColArr[A_Index] := A_Index
Msgbox % ColArr.MaxIndex() ; 3

; also supports chained assignments, and multi-line
arr := [], idx := 1, arr[idx] := "value1"
, test := 2, arr[test] := "value2"  ; comment
MsgBox % arr[2] ; value2