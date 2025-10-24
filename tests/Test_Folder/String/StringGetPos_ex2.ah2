text := "aaaaaa"
Loop 4 {
  search := "L" A_Index
  v1 := InStr(text, "a",, (SubStr(search, 1, 1) = "L" ? 1 : -1)*((0)+1), (SubStr(search, 1, 1) = "L" ? Trim(search, "L") : -Trim(search, "R"))) - 1
  v2 := InStr(text, "a",, (SubStr("R" . A_Index, 1, 1) = "L" ? 1 : -1)*((0)+1), (SubStr("R" . A_Index, 1, 1) = "L" ? Trim("R" . A_Index, "L") : -Trim("R" . A_Index, "R"))) - 1
  MsgBox(v1 "`n" v2)
}

c1 := InStr(text, "a",, (0)+1, 3) - 1
c2 := InStr(text, "a",, -1*((0)+1), -3) - 1
c1 := InStr(text, "a",, (2)+1, 3) - 1
c2 := InStr(text, "a",, -1*((2)+1), -3) - 1