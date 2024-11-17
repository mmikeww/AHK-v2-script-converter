Attributes := FileGetAttrib("C:\My File.txt")
if InStr(Attributes, "H")
    MsgBox("The file is hidden.")