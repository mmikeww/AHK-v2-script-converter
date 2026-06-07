; https://github.com/mmikeww/AHK-v2-script-converter/issues/409

count := ""
if count = 
    Goto, init

; Controls
a::
init:
count := 1
return

b::
count++
return

c::
MsgBox % count
return
