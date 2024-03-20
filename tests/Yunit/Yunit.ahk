#Requires AutoHotkey v2.0

class Yunit
{
    class Tester extends Yunit
    {
        __New(Modules)
        {
            this.Modules := Modules
        }
    }
    
    static Use(Modules*)
    {
        return (this.Tester)(Modules)
    }
    
    New(p*) => (o := {base: this}, o.__new(p*), o)
    
    Test(classes*) ; static method
    {
        instance := this.new("")
        instance.results := Map()
        instance.classes := classes
        instance.Modules := Array()
        for module in instance.base.Modules
            instance.Modules.Push(module(instance))
        for cls in classes
        {
            instance.current := A_Index
            instance.results[cls.prototype.__class] := obj := Map()
            instance.TestClass(obj, cls)
        }
    }
    
    Update(Category, Test, Result)
    {
        for module in this.Modules
            module.Update(Category, Test, Result)
    }
    
    TestClass(results, cls)
    {
        environment := cls() ; calls __New
        for k in cls.prototype.OwnProps()
        {
            if !(cls.prototype.%k% is Func)
                continue
            if (k = "Begin") or (k = "End") or (k = "__New") or (k == "__Delete")
                continue
            if environment.HasMethod("Begin") 
                environment.Begin()
            result := 0
            try
            {
                environment.%k%()
                if ObjHasOwnProp(environment, "ExpectedException")
                    throw Error("ExpectedException")
            }
            catch Error as err
            {
                if !ObjHasOwnProp(environment, "ExpectedException")
                || !this.CompareValues(environment.ExpectedException, err)
                    result := err
            }
            results[k] := result
            environment.DeleteProp("ExpectedException")
            this.Update(cls.prototype.__class, k, results[k])
            if environment.HasMethod("End")
                environment.End()
        }
        for k,v in cls.OwnProps()
            if v is Class
                this.classes.InsertAt(++this.current, v)
    }
    
    static Assert(Value, params*)
    {
        try
            Message := params[1]
        catch
            Message := "FAIL"
        if (!Value)
            throw Error(Message, -1)
    }
    
    CompareValues(v1, v2)
    {   ; Support for simple exceptions. May need to be extended in the future.
        if !IsObject(v1) || !IsObject(v2)
            return v1 = v2   ; obey StringCaseSense
        if !ObjHasOwnProp(v1, "Message") || !ObjHasOwnProp(v2, "Message")
            return False
        return v1.Message = v2.Message
    }
}
