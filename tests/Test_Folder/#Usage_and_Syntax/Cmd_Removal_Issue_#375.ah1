; https://github.com/mmikeww/AHK-v2-script-converter/issues/375

; the following line should have removal
AutoTrim, On

; NONE of the following should be removed
VarEndingWithAutoTrim := true
VarContainingAutoTrimInTheMiddle := false

if VarEndingWithAutoTrim <>
  MsgBox