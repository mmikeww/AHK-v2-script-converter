; REMOVED: #Warn UseUnsetGlobal
x := y
MsgBox(x)

; REMOVED: #Warn UseEnv
temp := ""
MsgBox(temp)


; REMOVED: #Warn ClassOverwrite
class MyClass {
    prop := "Hello, I am a class property."
}
MyClass := MyClass