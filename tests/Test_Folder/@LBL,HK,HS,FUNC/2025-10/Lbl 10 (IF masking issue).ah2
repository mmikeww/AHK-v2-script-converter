
LoadClipboardHistory() ; V1toV2:Gosub
LoadAutoTextList() ; V1toV2:Gosub

LoadClipboardHistory:
LoadClipboardHistory()
Return

LoadAutoTextList:
LoadAutoTextList()
Return

;###############  V1toV2 FUNCS  ###############
LoadClipboardHistory() { ; V1toV2: Lbl->Func
global
	if !FileExist(A_ScriptDir "\clipboard-history.txt")
		Return
Return
}
;##############################################
LoadAutoTextList() { ; V1toV2: Lbl->Func
global
	if !FileExist(A_ScriptDir "\clipboard-autotext.txt")
		Return
Return
}
