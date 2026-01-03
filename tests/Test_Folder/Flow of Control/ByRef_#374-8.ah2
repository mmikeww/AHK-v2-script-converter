func1(&a) {
  MsgBox(a)
  a := 1
  return "func1"
}

func2(&a, &b) {
  MsgBox(a . b)
  a := 1, b := 2
  return "func2"
}

func3(&a, &b, &c) {
  MsgBox(a . b . c)
  a := 1, b := 2, c := 3
  return "func3"
}


a := "a"
b := "b"
c := "c"
MsgBox(func3(&v2Param1:=func1(&a),&v2Param2:=func2(&a,&b),&v2Param3:=func1(&c)))