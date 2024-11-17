{   ErrorLevel := "ERROR"
   Try ErrorLevel := Run("ReadMe.doc", , "Max", )
}
if (ErrorLevel = "ERROR")
    MsgBox("The document could not be launched.")