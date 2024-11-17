var := "exe"
MyItemList := "bat,exe,com"

if (var ~= "^(?i:" RegExReplace(RegExReplace(MyItemList,"[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\s*,\s*","|") ")$")
    MsgBox(var " is in the list.")