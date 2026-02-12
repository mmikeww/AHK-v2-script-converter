var := [] ; will probably need to be added, but not within loops, etc
Loop 5 {
  ((var.Has(A_index) && var[A_index] := A_index) || var.Push(A_Index))
  MsgBox(var[A_index])
}