; https://github.com/mmikeww/AHK-v2-script-converter/issues/322

f::
MsgBox, You pressed f!
Return

g::MsgBox, You pressed g!

h::
GoSub, f
GoSub, g
Send, f
Send, g
Goto, f
Return