; https://github.com/mmikeww/AHK-v2-script-converter/issues/461

SC018::Send("{=}")	; capitol O key (orig example)

; use Ctrl+q to test these
^q::
{ ; V1toV2: Added opening brace for [^q]
global ; V1toV2: Made function global
Send("`;")
Send("{=}a")
SendInput("{=}b")
Send(":{=}c")
SendInput(":{=}d")
Send("=")
Send("=e")
SendInput("=f")
Send(":=g")
SendInput(":=h")
Send("{Raw}=")

; result for Ctrl+q
;=a=b:=c:=d==e=f:=g:=h=

return
} ; V1toV2: Added closing brace for [^q]