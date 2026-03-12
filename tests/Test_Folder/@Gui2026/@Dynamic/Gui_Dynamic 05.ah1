global Gui1 := {}
Gui1.W := 300, Gui1.H := 200, Gui1.X := 0, Gui1.Y := 0

makeGui()

f() {
  Gui, % Gui1.Hwnd ":Add", Text,, Text 2
  Gui, % Gui1.Hwnd ":Show", % "x0" " y0" " w" Gui1.W " h" Gui1.H "NA", % hwnd
}

MakeGui() {
  global
  Gui, 1: New, hwndhwnd
  Gui, Font, s15, Verdana
  Gui, 1: Add, Button, y20 gf, % "Click to add Text 2"
  Gui, Font, s22, Verdana
  Gui, 1: Add, Text,y+10, % "Text 1"
  Gui1.Hwnd := hwnd
  Gui, Show, % "x" Gui1.X " y" Gui1.Y " w" Gui1.W " h" Gui1.H, % Gui1.Hwnd
}