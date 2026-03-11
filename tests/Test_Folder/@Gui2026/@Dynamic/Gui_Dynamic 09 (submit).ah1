E1 := "e1", E2 := "e2", E3 := "e3"
x := (A_ScreenWidth/2)-320

gui, new
gui, add, text, y20, Edit these then press submit
loop 3
  ; has dynamic variable
  gui, add,edit,w100 vE%A_Index%, % E%A_index%
gui, add, button, gbtnSubmit, Submit
gui, show, x%x% w175 h150

return
btnSubmit:
gui Submit, nohide
varOutput := "New variable values:"
loop 3
  varOutput .= ("`nE" A_Index ":   """ E%A_index% """")
MsgBox % varOutput
return
