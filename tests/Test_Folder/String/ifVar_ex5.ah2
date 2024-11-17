IB := InputBox("", "Enter YES or NO"), UserInput := IB.Value
if !(UserInput ~= "^(?i:yes|no)$")
    MsgBox("Your input is not valid.")