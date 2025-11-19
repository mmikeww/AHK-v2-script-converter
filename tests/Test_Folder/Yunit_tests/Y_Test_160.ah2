title := WinGetTitle("A")
WinGetPos(&x, &y, &w, &h, "A")
MsgBox(title "-" w "-" h "-" x "-" y)