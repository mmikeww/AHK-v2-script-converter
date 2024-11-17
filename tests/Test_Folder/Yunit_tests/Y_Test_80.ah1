IfWinExist, ahk_class Notepad
   FileAppend, notepad is open, *
else
   FileAppend, notepad is not open, *