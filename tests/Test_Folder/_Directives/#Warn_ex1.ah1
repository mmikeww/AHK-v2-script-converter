#Warn UseUnsetGlobal
x := y
MsgBox % x

#Warn UseEnv
temp := ""
MsgBox % temp


#Warn ClassOverwrite
class MyClass {
    prop := "Hello, I am a class property."
}
MyClass := new MyClass