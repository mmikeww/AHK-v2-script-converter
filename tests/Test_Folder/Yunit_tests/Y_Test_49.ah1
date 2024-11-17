five := MyFunc()
FileAppend, %five%, *
MyFunc(var=5) {
   return var
}