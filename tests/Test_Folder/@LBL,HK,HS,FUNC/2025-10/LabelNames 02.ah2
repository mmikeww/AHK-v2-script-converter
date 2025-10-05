
; Demonstrate fix for label-to-func naming conflicts

; renaming label below will cause name conflict with this exisitng function
Go_here_1() {
 MsgBox("existing func that will cause name conflict")
}

; will conflict with existing function above
Go_here_1_2:

; will conflict with the other two
Go_here_1_3:
Go_here_1_3()
return

;###############  V1toV2 FUNCS  ###############
Go_here_1_3() { ; V1toV2: Lbl->Func
global
Go_here_1_3() ; V1toV2:Gosub ; recursion error
}
