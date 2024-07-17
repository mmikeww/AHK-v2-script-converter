
; Demonstrate fix for label-to-func naming conflicts

renaming label below will cause name conflict with this exisitng function
Go_here_1()
{
	MsgBox("existing func that will cause name conflict")
}

; will conflict with existing function above
	Go_here_1_2:

; will conflict with the other two
	Go_here_1_3()

{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Go_here_1_3()
} ; V1toV2: Added bracket in the end
