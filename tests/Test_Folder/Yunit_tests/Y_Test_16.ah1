var = %A_Now%
EnvAdd, var, 7, days
FormatTime, var, %var%, ShortDate
FileAppend, %var%, *