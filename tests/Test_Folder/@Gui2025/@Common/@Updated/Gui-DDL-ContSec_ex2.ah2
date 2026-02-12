myGui := Gui()
myGui.Add("DDL", "Choose5", ["A", "B", "C", "D", "E", "F"])


  /*
           block comment between fragments
  */


MsgBox("Line 1")

myGui.Add("DDL", "Choose6", ["A", "B", "C", "D", "E", "F"])
; line comment before fragments
; line comment between fragments
; line comment after fragments

MsgBox("Line 2")

myGui.Show()