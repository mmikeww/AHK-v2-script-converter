var := "exe"
MyItemList := "bat,exe,com"

if var in %MyItemList%
    MsgBox %var% is in the list.