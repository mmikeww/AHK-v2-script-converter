IfWinNotActive, ahk_class Notepad
   FileAppend, notepad is not Active, *
else
   FileAppend, notepad is Active, *