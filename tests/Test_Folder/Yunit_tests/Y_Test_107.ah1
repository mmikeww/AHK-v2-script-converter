half_second := 500
start := A_TickCount
Sleep, half_second
stop := A_TickCount
FileAppend, % stop - start, *