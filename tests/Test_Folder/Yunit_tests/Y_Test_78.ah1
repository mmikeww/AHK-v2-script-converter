IfWinActive, ahk_class Notepad
   FileAppend, notepad is Active, *
else
   FileAppend, notepad is not Active, *