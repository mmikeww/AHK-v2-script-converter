; Note ++ and -- are interchangable
i := 0

++ i ; valid (space)
--	i ; valid (tab)
i++ ; invalid (space)
i++ ; invalid (space)
i++ ; invalid (tab)

MsgBox(i) ; 3