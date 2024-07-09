
; Demonstrate fix for label-to-func naming conflicts

renaming label below will cause name conflict with this exisitng function
Go_here_1()
{
	msgbox existing func that will cause name conflict
}

; will conflict with existing function above
	Go_here%1:

; will conflict with the other two
	Go#here#1:

gosub Go#here#1
