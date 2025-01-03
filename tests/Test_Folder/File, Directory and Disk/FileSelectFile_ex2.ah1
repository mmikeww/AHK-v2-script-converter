FileSelectFile, MyVar
If not ErrorLevel
  MsgBox % MyVar
MsgBox %ErrorLevel%

FileSelectFile, MyVar, M
If not ErrorLevel
  MsgBox % MyVar
MsgBox %ErrorLevel%