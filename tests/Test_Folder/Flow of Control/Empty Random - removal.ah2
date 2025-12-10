
MsgBox(Rand())

Rand( a:=0.0, b:=1 ) {
   if (a = "")
      ; V1toV2: Removed Random reseed
      V1toV2_LineFill := true ; remove me after inspection
   Else r := Random(a, b)
   Return r
}