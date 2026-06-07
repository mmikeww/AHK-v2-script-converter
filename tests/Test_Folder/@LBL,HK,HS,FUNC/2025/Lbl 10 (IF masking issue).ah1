
gosub LoadClipboardHistory
gosub LoadAutoTextList

LoadClipboardHistory:
	IfNotExist, %A_ScriptDir%\clipboard-history.txt
		Return
Return

LoadAutoTextList:
	IfNotExist, %A_ScriptDir%\clipboard-autotext.txt
		Return
Return
