#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
global Gui1 := {}
Gui1.W := 300, Gui1.H := 200, Gui1.X := 0, Gui1.Y := 0

makeGui()

f(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
  (IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
  If (!HasV2Gui(Gui1.Hwnd)) {
    mV2Gui[Gui1.Hwnd] := NewV2Gui(Gui1.Hwnd)
  }
  mV2Gui[Gui1.Hwnd].Add("Text",,"Text 2")
  mV2Gui[Gui1.Hwnd].Title := hwnd
  mV2Gui[Gui1.Hwnd].Show("x0" " y0" " w" Gui1.W " h" Gui1.H "NA")
}

MakeGui() {
  global
  mV2Gui["1"] := NewV2Gui("1",1)
  hwnd := mV2Gui["1"].Hwnd
  mV2Gui[""].SetFont("s15","Verdana")
  mV2GC[["1","ClicktoaddText2"]] := mV2Gui["1"].Add("Button","y20","Click to add Text 2")
  mV2GC[["1","ClicktoaddText2"]].OnEvent("Click",f.Bind("Normal"))
  mV2Gui[""].SetFont("s22","Verdana")
  mV2Gui["1"].Add("Text","y+10","Text 1")
  Gui1.Hwnd := hwnd
  mV2Gui[""].Title := Gui1.Hwnd
  mV2Gui[""].Show("x" Gui1.X " y" Gui1.Y " w" Gui1.W " h" Gui1.H)
}