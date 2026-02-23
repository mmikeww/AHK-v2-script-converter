Gui, New, +resize +Labelmy_lbl
Gui, show, w100 h100

return
my_lblEscape:
msgbox escape
return

my_lblClose:
msgbox closing
exitapp
return

my_lblSize:
WinGetPos , X, Y, W, H
Tooltip x %x% y %y% w %w% h %h%
return