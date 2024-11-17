title := WinGetTitle("A")
WinGetPos(&x, &y, &w, &h, "A")
FileAppend(title "-" w "-" h "-" x "-" y, "*")