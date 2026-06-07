
^q::
{
  MsgBox % "I am HK ^q"
}

; LBL1 will not execute during script ini (due to HK above)
LBL1:
{ ; v1 lbl braces wont restrict execution within brace boundaries
  MsgBox % "I am LBL1, but execute with HK ^q"
  ; global code following lbl/HK with braces, is part of lbl/HK
} ; v1 execution continues past this point

LBL2:
{
  MsgBox % "I am LBL2, but execute with LBL1"
}

; this will only execute as part of label above it
MsgBox % "I am global, but execute with LBL2"
return

; this will not be executed at script startup
MsgBox % "I cannot be shown"