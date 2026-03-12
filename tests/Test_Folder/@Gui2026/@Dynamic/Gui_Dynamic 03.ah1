loop 3
{
  name := "gui" A_Index
  Gui, % name ":Add", Button,, % name " (B1)"
  ChangeGui(name)
}
return

ChangeGui(id)  ; v1 func, with dynamic gui handling
{
  static w := 600, h := 600
  w -= 125, h -= 125
  Gui, % id ":add", Button,, % id " (B2)"
  Gui, % id ":Show", % "w" w " h" h, % id
}