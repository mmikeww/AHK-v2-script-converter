; these are all VALID V1 label names
; V1 allows all character except whitespace, comma, and escape char.
; V2 allows ascii alphanumeric and underscore. But cannot start with a number. Does allow non-ascii characters.

renaming label below will cause name conflict with this exisitng function
_3_14()
{
	MsgBox("existing func that will cause name conflict")
}

; looks like a comment
	__notACommentAnymore:

; looks like variable de-reference path
	_A_Desktop__List_txt:

; looks like ahk directive
	_Persistent:

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

; begins with digit and has dot , will have name conflict with existing function
	_3_14_2:

; begins with digit and has dash, will have name conflict also
	_3_14_3()

{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
_3_14_3()
} ; V1toV2: Added bracket in the end
