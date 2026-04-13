i := 0
; Note ++ and -- are interchangeable

++ i ; v2 valid (space before var) [1]
--	i ; v2 valid (tab before var) [0]
i++ ; v2 INVALID (space AFTER var) [1]
i++ ; v2 INVALID (space AFTER var) [2]
i++ ; v2 INVALID (tab AFTER var) [3]

MsgBox(i) ; [3]