; these are all VALID V1 label names
; V1 allows all character except whitespace, comma, and escape char.
; V2 allows ascii alphanumeric and underscore. But cannot start with a number. Does allow non-ascii characters.

renaming label below will cause name conflict with this exisitng function
_3_14()
{
	msgbox existing func that will cause name conflict
}

; looks like a comment
	`;notACommentAnymore:

; looks like variable de-reference path
	%A_Desktop%\List.txt:

; looks like ahk directive
	#Persistent:

; valid in v2
	MYLABEL:
	
; non-ascii characters (Valid in v2)
	★a★b★c:

; non-ascii characters (NOT valid due to digit prefix)
	1★a★b★c:

; begins with colon			FIXED
	:a:

; looks like file path			FIXED
	c:\user\desktop\List.txt:

; looks like regex needle		FIXED
	\w+\(.*?\):

; looks like an if statement		FIXED
	if(a&&b){:

; looks like a function		FIXED
	IThoughtIWasAFunc(param1:=""){:

; begins with digit and has dot , will have name conflict with existing function
	3.14:

; begins with digit and has dash, will have name conflict also
	3-14:

gosub 3-14
