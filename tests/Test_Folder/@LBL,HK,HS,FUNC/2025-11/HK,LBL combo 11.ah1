; https://github.com/mmikeww/AHK-v2-script-converter/issues/413

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

; must move Goto below HK declaration
r::Goto init  ; reset