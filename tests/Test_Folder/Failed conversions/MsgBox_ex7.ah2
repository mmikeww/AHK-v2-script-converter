Switch Var
{
Case 1: msgResult := MsgBox("Test1")
Case 2: 
msgResult := MsgBox("Test2")
}
if (msgResult = "Ok")
  MsgBox()

Switch Var
{
Case 1: 
msgResult := MsgBox("Test1")
Case 2: 
msgResult := MsgBox("Test2")
}
if (msgResult = "Ok")
  MsgBox()