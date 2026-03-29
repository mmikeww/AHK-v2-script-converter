#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
mV2Gui["ping"] := NewV2Gui("ping",1)
mV2Gui[""].BackColor := "Black"
mV2Gui[""].SetFont("cWhite s12 bold")
mV2GC[["","PC_Ping"]] := mV2Gui[""].Add("Button","ReadOnly x5 y5 h10 w100 0x10 vPC_Ping")
mV2GC[["","User_Ping"]] := mV2Gui[""].Add("Button","ReadOnly x5 y485 h10 w100 0x10 vUser_Ping")
mV2GC[["","Pong"]] := mV2Gui[""].Add("Button","ReadOnly x240 y240 h10 w10 0x10 vPong")
mV2GC[["ping","Pong"]].Visible := false

mV2Gui[""].SetFont("cWhite s100 bold")
mV2GC[["","T1"]] := mV2Gui[""].add("text","x200 y170 vT1","3")
mV2GC[["","T2"]] := mV2Gui[""].add("text","x200 y170 vT2","2")
mV2GC[["","T3"]] := mV2Gui[""].add("text","x200 y170 vT3","1")
mV2GC[["","T4"]] := mV2Gui[""].add("text","x130 y170 vT4","GO!")

Loop 4
  fcV2GC("ping","T" . A_Index).Visible := false ; V1toV2: Verify that control [T%A_Index%] is accurate

mV2Gui[""].SetFont("cBlack s8","Verdana")
mV2GC[["","@STATUSBAR1"]] := mV2Gui[""].Add("StatusBar")
mV2Gui[""].Title := "PingPong"
mV2Gui[""].show("w500 h520")

Start_Game()

return
Start_Game()
{
  global
  mV2GC[["","@STATUSBAR1"]].SetText("")
  Loop 4 {
    Sleep(100)
    fcV2GC("ping","T" . A_Index).Visible := true ; V1toV2: Verify that control [T%A_Index%] is accurate
    Sleep(900)
    fcV2GC("ping","T" . A_Index).Visible := false ; V1toV2: Verify that control [T%A_Index%] is accurate
  }
  mV2GC[["ping","Pong"]].Move(240, 240)
  mV2GC[["ping","Pong"]].Visible := true
}