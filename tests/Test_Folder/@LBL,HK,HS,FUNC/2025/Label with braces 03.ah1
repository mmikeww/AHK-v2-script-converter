
gosub label2

label1:
{
msgbox % "label1 within braces"
return
}

; global code between labels

msgbox % "global code 1 (won't auto-execute)"
return

; comment preceding label 2

label2:
msgbox % "label2"
return