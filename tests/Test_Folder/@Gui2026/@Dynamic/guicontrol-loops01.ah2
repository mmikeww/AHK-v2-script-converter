; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
mV2Gui["ping"] := NewV2Gui("ping")
mV2Gui["ping"].BackColor := "Black"
mV2Gui["ping"].SetFont("cWhite s12 bold")
mV2GC[["ping","PC_Ping"]] := mV2Gui["ping"].Add("Button","ReadOnly x5 y5 h10 w100 0x10 vPC_Ping")
mV2GC[["ping","User_Ping"]] := mV2Gui["ping"].Add("Button","ReadOnly x5 y485 h10 w100 0x10 vUser_Ping")
mV2GC[["ping","Pong"]] := mV2Gui["ping"].Add("Button","ReadOnly x240 y240 h10 w10 0x10 vPong")
mV2GC[["ping","Pong"]].Visible := false

mV2Gui["ping"].SetFont("cWhite s100 bold")
mV2GC[["ping","T1"]] := mV2Gui["ping"].add("text","x200 y170 vT1","3")
mV2GC[["ping","T2"]] := mV2Gui["ping"].add("text","x200 y170 vT2","2")
mV2GC[["ping","T3"]] := mV2Gui["ping"].add("text","x200 y170 vT3","1")
mV2GC[["ping","T4"]] := mV2Gui["ping"].add("text","x130 y170 vT4","GO!")

Loop 4
  fcV2GC("ping","T" . A_Index).Visible := false ; V1toV2: Verify that control [T%A_Index%] is accurate

mV2Gui["ping"].SetFont("cBlack s8","Verdana")
mV2GC[["ping","@STATUSBAR1"]] := mV2Gui["ping"].Add("StatusBar")
mV2Gui["ping"].Title := "PingPong"
mV2Gui["ping"].show("w500 h520")

Start_Game()

return
Start_Game()
{
  global
  mV2GC[["ping","@STATUSBAR1"]].SetText("")
  Loop 4 {
    Sleep(100)
    fcV2GC("ping","T" . A_Index).Visible := true ; V1toV2: Verify that control [T%A_Index%] is accurate
    Sleep(900)
    fcV2GC("ping","T" . A_Index).Visible := false ; V1toV2: Verify that control [T%A_Index%] is accurate
  }
  mV2GC[["ping","Pong"]].Move(240, 240)
  mV2GC[["ping","Pong"]].Visible := true
}