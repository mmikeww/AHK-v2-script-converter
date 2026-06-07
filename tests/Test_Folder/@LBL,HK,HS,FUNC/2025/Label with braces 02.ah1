;Onexit, exit
return

+lbutton::	; comment 1
!lbutton::	; comment 2

	gosub, label_with_braces

return

; label with braces
label_with_braces:
{
	MsgBox label with braces
	; return
}

; comment after label_with_braces
;return

msgbox after label_with_braces

;return

func1() {
	msgbox func1
}

msgbox after func1

exit:
	msgbox exiting
	exitapp
return
