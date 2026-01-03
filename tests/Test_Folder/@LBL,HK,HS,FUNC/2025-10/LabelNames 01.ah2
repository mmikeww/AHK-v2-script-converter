#Warn Unreachable, Off
; these are all VALID V1 label names
; V1 allows all character except whitespace, comma, and escape char.
; V2 allows ascii alphanumeric and underscore. But cannot start with a number. Does allow non-ascii characters.

; renaming label below will cause name conflict with this exisitng function
_3_14()
{
	MsgBox("existing func that will cause name conflict")
}

; looks like a comment
	__notACommentAnymore:
__notACommentAnymore()
	return

; looks like variable de-reference path
	_A_Desktop__List_txt:
_A_Desktop__List_txt()
	return

; looks like ahk directive
	_Persistent:
_Persistent()
	return

; valid in v2
	MYLABEL:
MYLABEL()
	return

; non-ascii characters (NOT valid due to digit prefix)
	_1★a★b★c:
_1★a★b★c()
	return

; begins with colon
	_a:
_a()
	return

; looks like file path
	c__user_desktop_List_txt:
c__user_desktop_List_txt()
	return

; looks like regex needle
	_w________:
_w________()
	return

; begins with digit and has dot , will have name conflict with existing function
	_3_14_2:
_3_14_2()
	return

; begins with digit and has dash, will have name conflict also
	_3_14_3:
_3_14_3()
	return

V1toV2_GblCode_001:
V1toV2_GblCode_001()
return

; Tricky

;; looks like an if statement
;	if(a&&b){:
;	Msgbox % "if(a&&b){"
;	return

; non-ascii characters (Valid in v2)
	★a★b★c:
★a★b★c()
	return

; looks like a function
	IThoughtIWasAFunc_param1______:
IThoughtIWasAFunc_param1______()
	return

;###############  V1toV2 FUNCS  ###############
__notACommentAnymore() { ; V1toV2: Lbl->Func
global
	MsgBox("`;notACommentAnymore")
	return
}
;##############################################
_A_Desktop__List_txt() { ; V1toV2: Lbl->Func
global
	MsgBox("%A_Desktop%\List.txt")
	return
}
;##############################################
_Persistent() { ; V1toV2: Lbl->Func
global
	MsgBox("#Persistent")
	return
}
;##############################################
MYLABEL() { ; V1toV2: Lbl->Func
global
	MsgBox("MYLABEL")
	return
}
;##############################################
_1★a★b★c() { ; V1toV2: Lbl->Func
global
	MsgBox("1★a★b★c")
	return
}
;##############################################
_a() { ; V1toV2: Lbl->Func
global
	MsgBox(":a")
	return
}
;##############################################
c__user_desktop_List_txt() { ; V1toV2: Lbl->Func
global
	MsgBox("c:\user\desktop\List.txt")
	return
}
;##############################################
_w________() { ; V1toV2: Lbl->Func
global
	MsgBox("\w+\(.*?\)")
	return
}
;##############################################
_3_14_2() { ; V1toV2: Lbl->Func
global
	MsgBox("3.14")
	return
}
;##############################################
_3_14_3() { ; V1toV2: Lbl->Func
global
	MsgBox("3-14")
	return
}
;##############################################
V1toV2_GblCode_001() { ; V1toV2: Lbl->Func
global
_3_14_3() ; V1toV2: Gosub

return
}
;##############################################
★a★b★c() { ; V1toV2: Lbl->Func
global
	MsgBox("★a★b★c")
	return
}
;##############################################
IThoughtIWasAFunc_param1______() { ; V1toV2: Lbl->Func
global
	MsgBox("IThoughtIWasAFunc(param1:=`"){")
	return
}
