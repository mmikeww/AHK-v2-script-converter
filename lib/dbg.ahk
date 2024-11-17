dbgTT(dbgMin:=0, Text:="", Time:=.5,idTT:=1,X:=-1,Y:=-1) {
  if (dbg >= dbgMin) {
    TT(Text, Time,idTT,X,Y)
  }
}
TT(Text:="", Time:=.5,idTT:=1,X:=-1,Y:=-1) {
  MouseGetPos &mX, &mY, &mWin, &mControl
    ; mWin This optional parameter is the name of the variable in which to store the unique ID number of the window under the mouse cursor. If the window cannot be determined, this variable will be made blank.
    ; mControl This optional parameter is the name of the variable in which to store the name (ClassNN) of the control under the mouse cursor. If the control cannot be determined, this variable will be made blank.
  stepX := 0, stepY := 50 ; offset each subsequent ToolTip # from mouse cursor
  xFlag := SubStr(X, 1,1), yFlag := SubStr(Y, 1,1)
  if (xFlag="o") {
    stepX := SubStr(X, 2), X := -1
  }
  if (yFlag="o") {
    stepY := SubStr(Y, 2), Y := -1
  }
  if (dbg>6) {
    msgbox("X=" X " | xFlag=" xFlag " | stepX=" stepX "`n"
           "Y=" Y " | yFlag=" yFlag " | stepY=" stepY "`n"
           "SubStr:" SubStr("o200", 2) ) ;
  }

  if (X>=0 && Y>=0) {
    ToolTip(Text,X,Y,idTT)
  } else if (X>=0) {
    ToolTip(Text,X,mY+stepY*(idTT-1),idTT)
  } else if (Y>=0) {
    ToolTip(Text,mX+stepX*(idTT-1),Y,idTT)
  } else {
    ToolTip(Text,mX+stepX*(idTT-1),mY+stepY*(idTT-1),idTT)
  }
  SetTimer () => ToolTip(,,,idTT), -Time*1000
}
