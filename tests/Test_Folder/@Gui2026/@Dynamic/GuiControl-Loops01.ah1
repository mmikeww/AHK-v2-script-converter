gui, ping: new
gui, color, Black
gui, font, cWhite s12 bold
Gui, Add, Button, ReadOnly x5 y5 h10 w100 0x10 vPC_Ping
Gui, Add, Button, ReadOnly x5 y485 h10 w100 0x10 vUser_Ping
Gui, Add, Button, ReadOnly x240 y240 h10 w10 0x10 vPong
GuiControl, ping: Hide, Pong

gui, font, cWhite s100 bold
gui, add, text, x200 y170 vT1, 3
gui, add, text, x200 y170 vT2, 2
gui, add, text, x200 y170 vT3, 1
gui, add, text, x130 y170 vT4, GO!

Loop, 4
  GuiControl, ping: Hide, T%A_Index%

gui, font, cBlack s8, Verdana
Gui, Add, StatusBar,
gui, show, w500 h520, PingPong

Start_Game()

return
Start_Game()
{
  global
  SB_SetText("")
  Loop, 4 {
    sleep 100
    GuiControl, ping: Show, T%A_Index%
    sleep 900
    GuiControl, ping: Hide, T%A_Index%
  }
  GuiControl, ping: Move, Pong, % "x" 240 "y" 240
  GuiControl, ping: Show, Pong
}