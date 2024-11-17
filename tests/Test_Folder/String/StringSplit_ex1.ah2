TestString := "This is a test."
word_array := StrSplit(TestString,A_Space,".")  ; Omits periods.
MsgBox("The 4th word is " word_array[4] ".")