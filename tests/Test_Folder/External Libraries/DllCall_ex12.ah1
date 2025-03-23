VarSetCapacity(a, 4, 0)
VarSetCapacity(b, 16, 0)

DllCall("example.dll", "ptr", &a, "ptr", &b)