#Include ..\Yunit.ahk
#Include ..\Window.ahk
#Include ..\StdOut.ahk
#Include ..\JUnit.ahk
#Include ..\OutputDebug.ahk

Yunit.Use(YunitWindow, YunitJUnit, YunitOutputDebug).Test(NumberTestSuite, StringTestSuite)

class NumberTestSuite
{
    Begin()
    {
        this.x := 123
        this.y := 456
    }
    
    Test_Sum()
    {
        Yunit.assert(this.x + this.y == 579)
    }
    
    Test_Division()
    {
        Yunit.assert(this.x / this.y < 1)
        Yunit.assert(this.x / this.y > 0.25)
    }
    
    Test_Multiplication()
    {
        Yunit.assert(this.x * this.y == 56088)
    }
    
    End()
    {
        this.DeleteProp("x")
        this.DeleteProp("y")
    }
    
    class Negatives
    {
        Begin()
        {
            this.x := -123
            this.y := 456
        }
        
        Test_Sum()
        {
            Yunit.assert(this.x + this.y == 333)
        }
        
        Test_Division()
        {
            Yunit.assert(this.x / this.y > -1)
            Yunit.assert(this.x / this.y < -0.25)
        }
        
        Test_Multiplication()
        {
            Yunit.assert(this.x * this.y == -56088)
        }
        
        Test_Fails()
        {
            Yunit.assert(this.x - this.y == 0, "oops!")
        }
        
        Test_Fails_NoMessage()
        {
            Yunit.assert(this.x - this.y == 0)
        }

        End()
        {
            this.DeleteProp("x")
            this.DeleteProp("y")
        }
    }
}

class StringTestSuite
{
    Begin()
    {
        this.a := "abc"
        this.b := "cdef"
    }
    
    Test_Concat()
    {
        Yunit.assert(this.a . this.b == "abccdef")
    }
    
    Test_Substring()
    {
        Yunit.assert(SubStr(this.b, 2, 2) == "de")
    }
    
    Test_InStr()
    {
        Yunit.assert(InStr(this.a, "c") == 3)
    }
    
    Test_ExpectedException_Success()
    {
        this.ExpectedException := Error("SomeCustomException")
        if SubStr(this.a, 3, 1) == SubStr(this.b, 1, 1)
            throw Error("SomeCustomException")
    }
    
    Test_ExpectedException_Fail()
    {
        this.ExpectedException := "fubar"
        Yunit.assert(this.a != this.b)
        ; no exception thrown!
    }
    
    End()
    {
        this.DeleteProp("a")
        this.DeleteProp("b")
    }
}
