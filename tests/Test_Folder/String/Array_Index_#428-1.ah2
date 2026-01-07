
; avoid "Invalid Index" errors - issue #428

ColArr := []
Loop 3
  ColArr[A_Index] := A_Index ;  V1toV2: Invalid Index errors?, try 'ColArr.Push(<val>)'
MsgBox(ColArr.Length) ; 3 ; V1toV2: Verify V2 Length value = V1 MaxIndex

; also supports chained assignments, and multi-line
arr := [], idx := 1, arr[idx] := "value1"
, test := 2, arr[test] := "value2"  ; comment ;  V1toV2: Invalid Index errors?, try 'arr.Push(<val>)'
MsgBox(arr[2]) ; value2