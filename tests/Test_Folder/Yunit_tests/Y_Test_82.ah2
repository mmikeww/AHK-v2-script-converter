if !WinExist("ahk_class Notepad")
   FileAppend("notepad is not open", "*")
else
   FileAppend("notepad is open", "*")