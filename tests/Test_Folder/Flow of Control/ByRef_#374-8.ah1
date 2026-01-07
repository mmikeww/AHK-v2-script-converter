func1(byref a) {
  msgbox % a
  a := 1
  return "func1"
}

func2(byref a, byref b) {
  msgbox % a . b
  a := 1, b := 2
  return "func2"
}

func3(byref a, byref b, byref c) {
  msgbox % a . b . c
  a := 1, b := 2, c := 3
  return "func3"
}


a := "a"
b := "b"
c := "c"
msgbox % func3(func1(a),func2(a,b),func1(c))