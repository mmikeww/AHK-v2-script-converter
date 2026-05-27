#Warn Unreachable, Off
msg() ; V1toV2: Gosub
return
msg:
msg()
return

:*:test::
(

`;This is
`;a test
)

;###############  V1toV2 FUNCS  ###############
msg() { ; V1toV2: Lbl->Func
global
MsgBox("type `"test`" after closing this msgbox")
return
}