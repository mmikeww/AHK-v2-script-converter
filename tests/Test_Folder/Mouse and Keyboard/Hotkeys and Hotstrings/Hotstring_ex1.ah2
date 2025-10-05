Hotstring(":*X:]d", DatePaste)
Return

DatePaste:
DatePaste()
Return

;###############  V1toV2 FUNCS  ###############
DatePaste(*) { ; V1toV2: Lbl->Func
global
  Send(A_DD "-" A_MM "-" A_YYYY)
Return
}