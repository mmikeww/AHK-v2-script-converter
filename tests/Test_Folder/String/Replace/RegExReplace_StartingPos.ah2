MsgBox(RegExReplace("ababab", "b", "_", , , 1)) ; Returns a_a_a_
MsgBox(RegExReplace("ababab", "b", "_", , , -1)) ; Returns ababa_
MsgBox(RegExReplace("ababab", "b", "_", , , -2)) ; Returns ababa_
MsgBox(RegExReplace("ababab", "b", "_", , , -3)) ; Returns aba_a_
MsgBox(RegExReplace("ababab", "b", "_", , , -4)) ; Returns aba_a_
MsgBox(RegExReplace("ababab", "b", "_", , , -5)) ; Returns a_a_a_
