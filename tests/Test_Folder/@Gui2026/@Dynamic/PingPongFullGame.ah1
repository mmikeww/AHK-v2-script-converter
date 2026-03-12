#SingleInstance, force
SetControlDelay, -1
SetBatchLines, -1 ; for delay precision
Process, Priority, , R ; high CPU cooperation (maxed at 50 on dual affinity, use H otherwise)
SendMode, Input ; no Send delay

DllCall("SystemParametersInfo", UInt, 0xB, UInt, 20, UIntP, 0, UInt, 0) ; 0xB is SPI_SETKEYBOARDSPEED. 31 is the max speed, 0 is the min.
DllCall("SystemParametersInfo", UInt, 0x17, UInt, 0, UIntP, 0, UInt, 0) ; 0x17 is SPI_SETKEYBOARDDELAY. the first 0 is the shortest delay 250ms, 3 is the highest 1 sec

Your_Score := 0, PC_Score := 0

gui, ping: new
gui, ping: Default
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

Hotkey, IfWinActive, PingPong
Hotkey, Right, PingPong_Right
Hotkey, Left, PingPong_Left

Start_Game()
return

PingGuiEscape:
PingGuiClose:
ExitApp

PingPong_Right:
GuiControlGet, User_Ping, ping:Pos
if (User_PingX <= 400)
  GuiControl, ping: Move, User_Ping, % "x" User_PingX+15
return

PingPong_Left:
GuiControlGet, User_Ping, ping:Pos
if (User_PingX >= 0)
  GuiControl, ping: Move, User_Ping, % "x" User_PingX-15
return

Pong_Moves:
if (First_Game = true)
{
  Loop
  {
    GuiControlGet, Pong, ping:Pos
    GuiControlGet, User_Ping, ping:Pos
    GuiControlGet, PC_Ping, ping:Pos

    User_Full_Ping_Start := User_PingX ; user ping width coordinates
    User_Full_Ping_End := User_PingX + 100
    User_Ping_Middle := User_PingX + 50

    if (PongY = 475 and (PongX >= User_Full_Ping_Start and PongX <= User_Full_Ping_End)){
      Side_to_Side_User()
      gosub, Pong_Moves_UP
      return
    }
    else if (PongY < 490){
      GuiControl, ping: Move, Pong, % "y" PongY+5
      sleep 25
    }
    if (PongY > 485){
      Your_Score += 0
      PC_Score += 10
      if (Your_Score = 100){
        MsgBox, You have won! Your score is %Your_Score% vs PC score %PC_Score%
        return
      }
      if (PC_Score = 100){
        MsgBox, You have lost! Your score is %Your_Score% vs PC score %PC_Score%
        return
      }
      SB_SetText("You have lost! Your score " . Your_Score . " vs PC score " . PC_Score)
      sleep 2000
      Start_Game()
      return
    }
  }
}

if (First_Game = false)
{
  Loop
  {
    GuiControlGet, Pong, ping:Pos
    GuiControlGet, User_Ping, ping:Pos
    GuiControlGet, PC_Ping, ping:Pos

    User_Full_Ping_Start := User_PingX ; user ping width coordinates
    User_Full_Ping_End := User_PingX + 100
    User_Ping_Middle := User_PingX + 50

    if (PongY = 475 and (PongX >= User_Full_Ping_Start and PongX <= User_Full_Ping_End)){
      Side_to_Side_User()
      gosub, Pong_Moves_UP
      return
    }
    else if (PongY < 490){
      If (rotation = "Left" and PongX > 0){
        GuiControl, ping: Move, Pong, % "x" PongX-Rand(4, 6) "y" PongY+5
        sleep 20
      }
      If (rotation = "Left" and PongX <= 0){
        rotation := "Right"
        GuiControl, ping: Move, Pong, % "x" PongX+Rand(4, 6) "y" PongY+5
        sleep 20
      }
      If (rotation = "Right" and PongX < 490){
        GuiControl, ping: Move, Pong, % "x" PongX+Rand(4, 6) "y" PongY+5
        sleep 20
      }
      If (rotation = "Right" and PongX >= 490){
        rotation := "Left"
        GuiControl, ping: Move, Pong, % "x" PongX-Rand(4, 6) "y" PongY+5
        sleep 20
      }

    }
    if (PongY > 485){
      Your_Score += 0
      PC_Score += 10
      if (Your_Score = 100){
        MsgBox, You have won! Your score is %Your_Score% vs PC score %PC_Score%
        return
      }
      if (PC_Score = 100){
        MsgBox, You have lost! Your score is %Your_Score% vs PC score %PC_Score%
        return
      }
      SB_SetText("You have lost! Your score " . Your_Score . " vs PC score " . PC_Score)
      sleep 2000
      Start_Game()
      return
    }
  }
}
return

Pong_Moves_UP:
First_Game := false
Loop
{
  GuiControlGet, Pong, ping:Pos
  GuiControlGet, User_Ping, ping:Pos
  GuiControlGet, PC_Ping, ping:Pos

  PC_Ping_Start := PC_PingX ; user ping width coordinates
  PC_Ping_Middle := PC_PingX + 50
  PC_Ping_End := PC_PingX + 100
  Pong_End := PongX + 10

  if (PongY = 15 and (PongX >= PC_Ping_Start and PongX <= PC_Ping_End)){
    Side_to_Side_PC()
    gosub, Pong_Moves
    return
  }

  if (PC_Ping_Middle < PongX){
    GuiControl, ping: Move, PC_Ping, % "x" PC_PingX+4
  }
  if (PC_Ping_Middle > Pong_End){
    GuiControl, ping: Move, PC_Ping, % "x" PC_PingX-4
  }

  if (PongY <= 485){
    If (rotation = "Left" and PongX > 0){
      GuiControl, ping: Move, Pong, % "x" PongX-Rand(4, 6) "y" PongY-5
      sleep 20
    }
    If (rotation = "Left" and PongX <= 0){
      rotation := "Right"
      GuiControl, ping: Move, Pong, % "x" PongX+Rand(4, 6) "y" PongY-5
      sleep 20
    }
    If (rotation = "Right" and PongX < 490){
      GuiControl, ping: Move, Pong, % "x" PongX+Rand(4, 6) "y" PongY-5
      sleep 20
    }
    If (rotation = "Right" and PongX >= 490){
      rotation := "Left"
      GuiControl, ping: Move, Pong, % "x" PongX-Rand(4, 6) "y" PongY-5
      sleep 20
    }
  }

  if (PongY < 10){
    Your_Score += 10
    PC_Score += 0
    if (Your_Score = 100){
        MsgBox, You have won! Your score is %Your_Score% vs PC score %PC_Score%
        return
      }
    if (PC_Score = 100){
        MsgBox, You have lost! Your score is %Your_Score% vs PC score %PC_Score%
        return
      }
    SB_SetText("PC have lost! Your score " . Your_Score . " vs PC score " . PC_Score)
    sleep 2000
    Start_Game()
    return
  }
}
return

Start_Game()
{
  global
  SB_SetText("")
  Loop, 4
  {
    sleep 100
    GuiControl, ping: Show, T%A_Index%
    sleep 900
    GuiControl, ping: Hide, T%A_Index%
  }
  GuiControl, ping: Move, Pong, % "x" 240 "y" 240
  GuiControl, ping: Show, Pong
  sleep 400
  First_Game := true
  gosub, Pong_Moves
}

Side_to_Side_User()
{
  global
  if (User_Ping_Middle > PongX)
    rotation := "Left"
  if (User_Ping_Middle < PongX)
    rotation := "Right"
  return, rotation
}

Side_to_Side_PC()
{
  global
  if (PC_Ping_Middle > PongX)
    rotation := "Left"
  if (PC_Ping_Middle < PongX)
    rotation := "Right"
  return, rotation
}

Rand( a=0.0, b=1 ) {
   IfEqual,a,,Random,,% r := b = 1 ? Rand(0,0xFFFFFFFF) : b
   Else Random,r,a,b
   Return r
}