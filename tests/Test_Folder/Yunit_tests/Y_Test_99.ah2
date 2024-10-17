FileAppend(MyFunc(), "*")

MyFunc() {
   var := "hi"
   return (AHKv1v2_Temp := OtherFunc(var, "world", 3), AHKv1v2_Temp) ; V1toV2: Wrapped Multi-statement return with parentheses
}

OtherFunc(one, two, three) {
   return one . two
}