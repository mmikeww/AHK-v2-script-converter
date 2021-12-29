WinGetTitle, active_title, A
if active_title contains Address List.txt,Customer List.txt
    MsgBox One of the desired windows is active.
if active_title not contains metapad,Notepad
    MsgBox But the file is not open in either Metapad or Notepad.