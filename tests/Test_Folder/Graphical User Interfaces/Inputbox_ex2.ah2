IB := InputBox("Please enter a phone number.", "Phone Number", "w640 h480"), UserInput := IB.Value , ErrorLevel := IB.Result="OK" ? 0 : IB.Result="CANCEL" ? 1 : IB.Result="Timeout" ? 2 : "ERROR"
if ErrorLevel
    msgResult := MsgBox("CANCEL was pressed.")
else
    msgResult := MsgBox("You entered `"" . UserInput . "`"")