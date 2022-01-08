var = val

IfEqual, var, val, MsgBox,
(
    1p simple
)

IfEqual, var, val, MsgBox % "
(
    1p forced
)"

IfEqual, var, val, MsgBox, 1, title,
(
    4p simple only text
)

IfEqual, var, val, MsgBox, 1, title, % "
(
    4p forced only text
)"

IfEqual, var, val, MsgBox, 1, title,
(
    4p simple with timeout
), 4

IfEqual, var, val, MsgBox, 1, title, % "
(
    4p forced with timeout
)", 4