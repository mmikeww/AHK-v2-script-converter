class YunitStdOut
{
    Update(Category, Test, Result) ;wip: this only supports one level of nesting?
    {
        if IsObject(Result)
        {
            Details := " at line " Result.Line " " Result.Message
            Status := "FAIL"
        }
        else
        {
            Details := ""
            Status := "PASS"
        }
        FileAppend, %Status%: %Category%.%Test% %Details%`n, *
    }
}