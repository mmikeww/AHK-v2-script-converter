if MyFunc()
   MsgBox, %var%

MyFunc() {
   global var := 777
   return true
}