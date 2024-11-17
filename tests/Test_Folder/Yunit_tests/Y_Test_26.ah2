if MyFunc()
   FileAppend(var, "*")

MyFunc() {
   global var := 777
   return true
}