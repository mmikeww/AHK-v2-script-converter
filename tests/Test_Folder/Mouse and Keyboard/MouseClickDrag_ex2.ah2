Run("mspaint.exe")
ErrorLevel := !WinWaitActive("ahk_class MSPaintApp", , 2)
if ErrorLevel
    return
MouseClickDrag("L", 150, 250, 150, 150)
MouseClickDrag("L", 150, 150, 200, 100)
MouseClickDrag("L", 200, 100, 250, 150)
MouseClickDrag("L", 250, 150, 150, 150)
MouseClickDrag("L", 150, 150, 250, 250)
MouseClickDrag("L", 250, 250, 250, 150)
MouseClickDrag("L", 250, 150, 150, 250)
MouseClickDrag("L", 150, 250, 250, 250)