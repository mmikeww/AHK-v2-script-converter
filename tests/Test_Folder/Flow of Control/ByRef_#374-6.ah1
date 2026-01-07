test := New clsTest()
test.m1()
test.m3()

Class clsTest {
  prop1 := ""

  m1() {
    this.prop1 := "1"
    this.m2(this.prop1,"")
    MsgBox % "[" this.prop1 "] NOT changed`nfrom m1"
  }

  m2(ByRef a, b) {
    MsgBox % "[" a "]`nfrom m2"
    a := "2"
  }

  m3() {
    localProp := "3"
    this.m2(localProp, "")
    MsgBox % "[" localProp "] Changed`nfrom m3"
  }
}