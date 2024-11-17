Tray:= A_TrayMenu
Tray.Add(arg3, % arg3)
Tray.Add(func_arg3(nestedArg1, nestedArg2), % func_arg3(nestedArg1, nestedArg2))

Tray.Add(arg3, arg4)
Tray.Add(func_arg3(nestedArg3a, nestedArg3b), func_arg4(nestedArg4a, nestedArg4b))

Tray.Add(arg3, arg4, "arg5")
Tray.Add(func_arg3(nestedArg3a, nestedArg3b), func_arg4(nestedArg4a, nestedArg4b), "func_arg5(nestedArg5a, nestedArg5b)")
