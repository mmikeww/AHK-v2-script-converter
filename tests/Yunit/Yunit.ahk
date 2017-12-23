;#NoEnv

class Yunit
{
    static Modules := [Yunit.StdOut]
    
    class Tester extends Yunit
    {
        __New(Modules)
        {
            this.Modules := Modules
        }
    }
    
    Use(Modules*)
    {
        return new this.Tester(Modules)
    }
    
    Test(classes*) ; static method
    {
        instance := new this("")
        instance.results := {}
        instance.classes := classes
        instance.Modules := []
        for k,module in instance.base.Modules
            instance.Modules[k] := new module(instance)
        while (A_Index <= classes.Length())
        {
            cls := classes[A_Index]
            instance.current := A_Index
            instance.results[cls.__class] := obj := {}
            instance.TestClass(obj, cls)
        }
    }
    
    Update(Category, Test, Result)
    {
        for k,module in this.Modules
            module.Update(Category, Test, Result)
    }
    
    TestClass(results, cls)
    {
        environment := new cls() ; calls __New
        for k,v in cls
        {
            if IsObject(v) && IsFunc(v) ;test
            {
                if (k = "Begin") or (k = "End")
                    continue
                if ObjHasKey(cls,"Begin") 
                && IsFunc(cls.Begin)
                    environment.Begin()
                result := 0
                try
                {
                    %v%(environment)
                    if ObjHasKey(environment, "ExpectedException")
                        throw Exception("ExpectedException")
                }
                catch error
                {
                    if !ObjHasKey(environment, "ExpectedException")
                    || !this.CompareValues(environment.ExpectedException, error)
                        result := error
                }
                results[k] := result
                ObjDelete(environment, "ExpectedException")
                this.Update(cls.__class, k, results[k])
                if ObjHasKey(cls,"End")
                && IsFunc(cls.End)
                    environment.End()
            }
            else if IsObject(v)
            && ObjHasKey(v, "__class") ;category
                this.classes.InsertAt(++this.current, v)
        }
    }
    
    Assert(Value, params*)
    {
        Message := (params[1] = "") ? "FAIL" : params[1]
        if (!Value)
            throw Exception(Message, -2)
    }
    
    CompareValues(v1, v2)
    {   ; Support for simple exceptions. May need to be extended in the future.
        if !IsObject(v1) || !IsObject(v2)
            return v1 = v2   ; obey StringCaseSense
        if !ObjHasKey(v1, "Message") || !ObjHasKey(v2, "Message")
            return False
        return v1.Message = v2.Message
    }
}
