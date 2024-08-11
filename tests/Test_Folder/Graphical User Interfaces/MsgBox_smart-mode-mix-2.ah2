MsgBox
(
1
)  ; 1-p
MsgBox("a, 22, 
(
    33
), 44")  ; 1-p mode


MsgBox("", "22
(
    
)", 1)  ; 4-p mode
MsgBox(
(
33
), 22, 1)  ; 4-p mode

MsgBox(
(
33
), 22, "1 T44")  ; 4-p
MsgBox("
(
    33
), dd", 22, 1)  ; 4-p (no timeout)

MsgBox("
(
    33
), 44, 55", 22, 1)  ; 4-p (no timeout)