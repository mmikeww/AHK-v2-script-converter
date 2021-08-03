class YunitStdOut
{
    __new(instance)
    {
    }

    Update(Category, Test, Result) ;wip: this only supports one level of nesting?
    {
        if Result is Error
        {
            Details := " at line " Result.Line " " Result.Message "(" Result.File ")"
            Status := "FAIL"
        }
        else
        {
            Details := ""
            Status := "PASS"
        }
        FileAppend Status ": " Category "." Test " " Details "`n", "*"
    }
}
