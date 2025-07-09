MyVar := ComObjMissing()

ComObj(0x10, MyVar)
ComObj(MyVar, 0x10)
ComObj(MyVar, MyVar)

ComObj(0x10, ComObjMissing())
ComObj(ComObjMissing(), 0x10)
ComObj(ComObjMissing(), ComObjMissing())

Var1 := "test", Var2 := ComObjMissing()
Var3 := ComObjMissing(), Var4 := "test"
Var5 := ComObjMissing(), Var6 := ComObjMissing()