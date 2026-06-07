
^q::
{
  var := "-10"
  MsgBox % "I am HK ^q"

  LBL1:
  MsgBox % "I am nested LBL1" . var

  LBL2:
  MsgBox % "I am nested LBL2" . var
}

MsgBox % "I am global, but execute with HK ^q"
return