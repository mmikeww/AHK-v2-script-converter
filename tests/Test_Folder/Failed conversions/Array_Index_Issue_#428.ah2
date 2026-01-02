ColArr := []
Loop 3
  ((ColArr.Has(A_Index)) && ColArr[A_Index] := A_Index) || ColArr.Push(A_Index)

MsgBox(ColArr.Length) ; 3 ; V1toV2: Verify V2 Length value = V1 MaxIndex