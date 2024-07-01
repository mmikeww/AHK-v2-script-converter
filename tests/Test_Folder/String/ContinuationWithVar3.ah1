user := "hello"

; with continuation block
script1 =
(
	document.querySelector('#userId').value = '%user%'
)
msgbox % "script1:`n`n[" script1 "]"

; without continuation block
script2 = document.querySelector('#userId').value = '%user%'
msgbox % "script2:`n`n[" script2 "]"

same := (script1==script2)
msgbox % "same: " same