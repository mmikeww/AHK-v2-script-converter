MyVar := FileSelect()
if (MyVar = "") {
ErrorLevel := 1
} else {
ErrorLevel := 0
}
If not ErrorLevel
  MsgBox(MyVar)
MsgBox(ErrorLevel)

oMyVar := FileSelect("M")
for FileName in oMyVar
{
MyVar .= A_index=2 ? "`r`n" : ""
MyVar .= A_index=1 ? FileName : RegExReplace(FileName,"^.*\\([^\\]*)$" ,"$1") "`r`n"
}
if (MyVar = "") {
ErrorLevel := 1
} else {
ErrorLevel := 0
}
If not ErrorLevel
  MsgBox(MyVar)
MsgBox(ErrorLevel)