; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
#SingleInstance force
SetControlDelay(-1)
; V1toV2: Removed SetBatchLines, -1 ; for delay precision
ProcessSetPriority("R") ; high CPU cooperation (maxed at 50 on dual affinity, use H otherwise)
SendMode("Input") ; no Send delay

DllCall("SystemParametersInfo", "UInt", 0xB, "UInt", 20, "UIntP", 0, "UInt", 0) ; 0xB is SPI_SETKEYBOARDSPEED. 31 is the max speed, 0 is the min.
DllCall("SystemParametersInfo", "UInt", 0x17, "UInt", 0, "UIntP", 0, "UInt", 0) ; 0x17 is SPI_SETKEYBOARDDELAY. the first 0 is the shortest delay 250ms, 3 is the highest 1 sec

Your_Score := 0, PC_Score := 0

mV2Gui["ping"] := NewV2Gui("ping")
mV2Gui["ping"].OnEvent("Close",PingGuiClose)
mV2Gui["ping"].OnEvent("Escape",PingGuiEscape)
;gui, ping: Default ; V1toV2: removed, but applied
V1toV2_LineFill := true ; remove me after inspection
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

HotIfWinActive("PingPong")
Hotkey("Right", PingPong_Right)
Hotkey("Left", PingPong_Left)

Start_Game()
return

PingGuiEscape:
PingGuiEscape()
return
PingGuiClose:
PingGuiClose()
ExitApp()

PingPong_Right:
PingPong_Right()
return

PingPong_Left:
PingPong_Left()
return

Pong_Moves:
Pong_Moves()
return

Pong_Moves_UP:
Pong_Moves_UP()
return

Start_Game()
{
  global
  mV2GC[["ping","@STATUSBAR1"]].SetText("")
  Loop 4
  {
    Sleep(100)
    fcV2GC("ping","T" . A_Index).Visible := true ; V1toV2: Verify that control [T%A_Index%] is accurate
    Sleep(900)
    fcV2GC("ping","T" . A_Index).Visible := false ; V1toV2: Verify that control [T%A_Index%] is accurate
  }
  mV2GC[["ping","Pong"]].Move(240, 240)
  mV2GC[["ping","Pong"]].Visible := true
  Sleep(400)
  First_Game := true
  Pong_Moves() ; V1toV2: Gosub
}

Side_to_Side_User()
{
  global
  if (User_Ping_Middle > PongX)
    rotation := "Left"
  if (User_Ping_Middle < PongX)
    rotation := "Right"
  return rotation
}

Side_to_Side_PC()
{
  global
  if (PC_Ping_Middle > PongX)
    rotation := "Left"
  if (PC_Ping_Middle < PongX)
    rotation := "Right"
  return rotation
}

Rand( a:=0.0, b:=1 ) {
   if (a = "")
      ; V1toV2: Removed Random reseed
      V1toV2_LineFill := true ; remove me after inspection
   Else r := Random(a, b)
   Return r
}

;###############  V1toV2 FUNCS  ###############
PingGuiEscape(*) { ; V1toV2: Lbl->Func
global
PingGuiClose()
}
;##############################################
PingGuiClose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}
;##############################################
PingPong_Right(ThisHotkey:="") { ; V1toV2: Lbl->Func
global
mV2GC[["ping","User_Ping"]].GetPos(&User_PingX, &User_PingY, &User_PingW, &User_PingH)
if (User_PingX <= 400)
  mV2GC[["ping","User_Ping"]].Move(User_PingX+15)
return
}
;##############################################
PingPong_Left(ThisHotkey:="") { ; V1toV2: Lbl->Func
global
mV2GC[["ping","User_Ping"]].GetPos(&User_PingX, &User_PingY, &User_PingW, &User_PingH)
if (User_PingX >= 0)
  mV2GC[["ping","User_Ping"]].Move(User_PingX-15)
return
}
;##############################################
Pong_Moves() { ; V1toV2: Lbl->Func
global
if (First_Game = true)
{
  Loop
  {
    mV2GC[["ping","Pong"]].GetPos(&PongX, &PongY, &PongW, &PongH)
    mV2GC[["ping","User_Ping"]].GetPos(&User_PingX, &User_PingY, &User_PingW, &User_PingH)
    mV2GC[["ping","PC_Ping"]].GetPos(&PC_PingX, &PC_PingY, &PC_PingW, &PC_PingH)

    User_Full_Ping_Start := User_PingX ; user ping width coordinates
    User_Full_Ping_End := User_PingX + 100
    User_Ping_Middle := User_PingX + 50

    if (PongY = 475 and (PongX >= User_Full_Ping_Start and PongX <= User_Full_Ping_End)){
      Side_to_Side_User()
      Pong_Moves_UP() ; V1toV2: Gosub
      return
    }
    else if (PongY < 490){
      mV2GC[["ping","Pong"]].Move(, PongY+5)
      Sleep(25)
    }
    if (PongY > 485){
      Your_Score += 0
      PC_Score += 10
      if (Your_Score = 100){
        MsgBox("You have won! Your score is " Your_Score " vs PC score " PC_Score)
        return
      }
      if (PC_Score = 100){
        MsgBox("You have lost! Your score is " Your_Score " vs PC score " PC_Score)
        return
      }
      mV2GC[["ping","@STATUSBAR1"]].SetText("You have lost! Your score " . Your_Score . " vs PC score " . PC_Score)
      Sleep(2000)
      Start_Game()
      return
    }
  }
}

if (First_Game = false)
{
  Loop
  {
    mV2GC[["ping","Pong"]].GetPos(&PongX, &PongY, &PongW, &PongH)
    mV2GC[["ping","User_Ping"]].GetPos(&User_PingX, &User_PingY, &User_PingW, &User_PingH)
    mV2GC[["ping","PC_Ping"]].GetPos(&PC_PingX, &PC_PingY, &PC_PingW, &PC_PingH)

    User_Full_Ping_Start := User_PingX ; user ping width coordinates
    User_Full_Ping_End := User_PingX + 100
    User_Ping_Middle := User_PingX + 50

    if (PongY = 475 and (PongX >= User_Full_Ping_Start and PongX <= User_Full_Ping_End)){
      Side_to_Side_User()
      Pong_Moves_UP() ; V1toV2: Gosub
      return
    }
    else if (PongY < 490){
      If (rotation = "Left" and PongX > 0){
        mV2GC[["ping","Pong"]].Move(PongX-Rand(4, 6), PongY+5)
        Sleep(20)
      }
      If (rotation = "Left" and PongX <= 0){
        rotation := "Right"
        mV2GC[["ping","Pong"]].Move(PongX+Rand(4, 6), PongY+5)
        Sleep(20)
      }
      If (rotation = "Right" and PongX < 490){
        mV2GC[["ping","Pong"]].Move(PongX+Rand(4, 6), PongY+5)
        Sleep(20)
      }
      If (rotation = "Right" and PongX >= 490){
        rotation := "Left"
        mV2GC[["ping","Pong"]].Move(PongX-Rand(4, 6), PongY+5)
        Sleep(20)
      }

    }
    if (PongY > 485){
      Your_Score += 0
      PC_Score += 10
      if (Your_Score = 100){
        MsgBox("You have won! Your score is " Your_Score " vs PC score " PC_Score)
        return
      }
      if (PC_Score = 100){
        MsgBox("You have lost! Your score is " Your_Score " vs PC score " PC_Score)
        return
      }
      mV2GC[["ping","@STATUSBAR1"]].SetText("You have lost! Your score " . Your_Score . " vs PC score " . PC_Score)
      Sleep(2000)
      Start_Game()
      return
    }
  }
}
return
}
;##############################################
Pong_Moves_UP() { ; V1toV2: Lbl->Func
global
First_Game := false
Loop
{
  mV2GC[["ping","Pong"]].GetPos(&PongX, &PongY, &PongW, &PongH)
  mV2GC[["ping","User_Ping"]].GetPos(&User_PingX, &User_PingY, &User_PingW, &User_PingH)
  mV2GC[["ping","PC_Ping"]].GetPos(&PC_PingX, &PC_PingY, &PC_PingW, &PC_PingH)

  PC_Ping_Start := PC_PingX ; user ping width coordinates
  PC_Ping_Middle := PC_PingX + 50
  PC_Ping_End := PC_PingX + 100
  Pong_End := PongX + 10

  if (PongY = 15 and (PongX >= PC_Ping_Start and PongX <= PC_Ping_End)){
    Side_to_Side_PC()
    Pong_Moves() ; V1toV2: Gosub
    return
  }

  if (PC_Ping_Middle < PongX){
    mV2GC[["ping","PC_Ping"]].Move(PC_PingX+4)
  }
  if (PC_Ping_Middle > Pong_End){
    mV2GC[["ping","PC_Ping"]].Move(PC_PingX-4)
  }

  if (PongY <= 485){
    If (rotation = "Left" and PongX > 0){
      mV2GC[["ping","Pong"]].Move(PongX-Rand(4, 6), PongY-5)
      Sleep(20)
    }
    If (rotation = "Left" and PongX <= 0){
      rotation := "Right"
      mV2GC[["ping","Pong"]].Move(PongX+Rand(4, 6), PongY-5)
      Sleep(20)
    }
    If (rotation = "Right" and PongX < 490){
      mV2GC[["ping","Pong"]].Move(PongX+Rand(4, 6), PongY-5)
      Sleep(20)
    }
    If (rotation = "Right" and PongX >= 490){
      rotation := "Left"
      mV2GC[["ping","Pong"]].Move(PongX-Rand(4, 6), PongY-5)
      Sleep(20)
    }
  }

  if (PongY < 10){
    Your_Score += 10
    PC_Score += 0
    if (Your_Score = 100){
        MsgBox("You have won! Your score is " Your_Score " vs PC score " PC_Score)
        return
      }
    if (PC_Score = 100){
        MsgBox("You have lost! Your score is " Your_Score " vs PC score " PC_Score)
        return
      }
    mV2GC[["ping","@STATUSBAR1"]].SetText("PC have lost! Your score " . Your_Score . " vs PC score " . PC_Score)
    Sleep(2000)
    Start_Game()
    return
  }
}
return
}