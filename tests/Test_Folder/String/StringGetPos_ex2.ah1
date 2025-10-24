text := "aaaaaa"
Loop, 4 {
  search := "L" A_Index
  StringGetPos, v1, text, a, % search
  StringGetPos, v2, text, a, % "R" . A_Index
  MsgBox % v1 "`n" v2
}

StringGetPos, c1, text, a, L3
StringGetPos, c2, text, a, R3
StringGetPos, c1, text, a, L3, 2
StringGetPos, c2, text, a, R3, 2