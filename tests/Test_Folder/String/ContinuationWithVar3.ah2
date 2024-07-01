user := "hello"

; with continuation block
script1 :=
(
	 "document.querySelector('#userId').value = '" . user . "'"
)
MsgBox("script1:`n`n[" script1 "]")

; without continuation block
script2 := "document.querySelector('#userId').value = '" . user . "'"
MsgBox("script2:`n`n[" script2 "]")

same := (script1==script2)
MsgBox("same: " same)