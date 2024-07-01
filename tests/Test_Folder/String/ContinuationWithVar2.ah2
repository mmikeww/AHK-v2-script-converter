user := "defaultuser0"
script :=
(
	 "document.querySelector('#userId').value = '" . user . "'"
)
MsgBox(script)



MyVar := "Test"
MySection :=
(
	 "This is a " . MyVar
)

MsgBox(MySection)