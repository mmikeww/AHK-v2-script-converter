FileAppend(MyFunc(), "*")

MyFunc() {
   var := "hi"
   return OtherFunc(var, "world", 3)
}

OtherFunc(one, two, three) {
   return one . two
}