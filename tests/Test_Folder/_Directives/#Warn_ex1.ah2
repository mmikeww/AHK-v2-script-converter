; V1toV2: Removed #Warn UseUnsetGlobal
x := y
MsgBox(x)

; V1toV2: Removed #Warn UseEnv
temp := ""
MsgBox(temp)


; V1toV2: Removed #Warn ClassOverwrite
class MyClass {
    prop := "Hello, I am a class property."
}
MyClass := MyClass