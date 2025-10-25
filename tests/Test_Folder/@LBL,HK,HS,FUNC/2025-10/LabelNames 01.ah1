; these are all VALID V1 label names
; V1 allows all character except whitespace, comma, and escape char.
; V2 allows ascii alphanumeric and underscore. But cannot start with a number. Does allow non-ascii characters.

; renaming label below will cause name conflict with this exisitng function
_3_14()
{
	msgbox existing func that will cause name conflict
}

; looks like a comment
	`;notACommentAnymore:
	Msgbox % "`;notACommentAnymore"
	return

; looks like variable de-reference path
	%A_Desktop%\List.txt:
	Msgbox % "%A_Desktop%\List.txt"
	return

; looks like ahk directive
	#Persistent:
	Msgbox % "#Persistent"
	return

; valid in v2
	MYLABEL:
	Msgbox % "MYLABEL"
	return

; non-ascii characters (NOT valid due to digit prefix)
	1★a★b★c:
	Msgbox % "1★a★b★c"
	return

; begins with colon
	:a:
	Msgbox % ":a"
	return

; looks like file path
	c:\user\desktop\List.txt:
	Msgbox % "c:\user\desktop\List.txt"
	return

; looks like regex needle
	\w+\(.*?\):
	Msgbox % "\w+\(.*?\)"
	return

; begins with digit and has dot , will have name conflict with existing function
	3.14:
	Msgbox % "3.14"
	return

; begins with digit and has dash, will have name conflict also
	3-14:
	Msgbox % "3-14"
	return

gosub 3-14

return

; Tricky

;; looks like an if statement
;	if(a&&b){:
;	Msgbox % "if(a&&b){"
;	return

; non-ascii characters (Valid in v2)
	★a★b★c:
	Msgbox % "★a★b★c"
	return

; looks like a function
	IThoughtIWasAFunc(param1:=""){:
	Msgbox % "IThoughtIWasAFunc(param1:=""){"
	return
