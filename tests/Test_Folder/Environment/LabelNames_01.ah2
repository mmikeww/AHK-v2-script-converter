
; these are all VALID V1 label names
; V1 allows all character except whitespace, comma, and escape char.
; V2 allows ascii alphanumeric and underscore. But cannot start with a number. Does allow non-ascii characters.

; looks like a comment
	__notACommentAnymore:

; looks like variable de-reference path
	_A_Desktop__List_txt:

; looks like ahk directive
	_Persistent:

; begins with digit and has dot
	_3_14:

; valid in v2
	MYLABEL:
	
; non-ascii characters (Valid in v2)
	★a★b★c:

; non-ascii characters (NOT valid due to digit prefix)
	_1★a★b★c:

; begins with colon			FIXED
	_a:

; looks like file path			FIXED
	c__user_desktop_List_txt:

; looks like regex needle		FIXED
	_w________:

; looks like an if statement		FIXED
	if_a__b__:

; looks like a function		FIXED
	IThoughtIWasAFunc_param1______: