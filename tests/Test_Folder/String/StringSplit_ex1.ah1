TestString := "This is a test."
StringSplit, word_array, TestString, %A_Space%, .  ; Omits periods.
MsgBox, The 4th word is %word_array4%.