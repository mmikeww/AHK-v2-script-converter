MsgBox("HIDE", A_ComSpec " /c `"`"schtasks`" `"/run`" `"/tn`" `"MY\cmdtab`"`"", 1)
MsgBox("Test", A_ComSpec " text `"`"string`" `"string`"`"", 1)

MsgBox("ABC", "`"`"`"`"`"`"`"", 0)
MsgBox("ABC", "`"`"`"`"`"", 0)