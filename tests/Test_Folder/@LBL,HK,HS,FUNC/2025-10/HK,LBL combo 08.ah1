gosub label1
return

label1:
msgbox % "label1"
return

; global code
msgbox % "global1"
return

msgbox % "global2"
return

q::
func1(){
w := 10
h := 20
msgbox % "hotkey"
return {w:w,h:h}
}