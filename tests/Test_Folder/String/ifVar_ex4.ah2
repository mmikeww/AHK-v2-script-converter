var := "exe"
MyItemList := "bat,exe,com"

if (var ~= "^(?i:" RegExReplace(RegExReplace(MyItemList,"[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\h*,\h*","|") ")$")
    MsgBox(var " is in the list.")