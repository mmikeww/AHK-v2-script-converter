half_second := 500
start := A_TickCount
Sleep, % half_second*2
stop := A_TickCount
FileAppend, % stop - start, *