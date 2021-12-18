var1 := "abc"
var2 := 123
MsgBox % Deref("%var1%def%var2%")  ; Reports abcdef123.

Deref(Str)
{
    spo := 1
    out := ""
    while (fpo:=RegExMatch(Str, "(%(.*?)%)|``(.)", m, spo))
    {
        out .= SubStr(Str, spo, fpo-spo)
        spo := fpo + StrLen(m)
        if (m1)
            out .= %m2%
        else switch (m3)
        {
            case "a": out .= "`a"
            case "b": out .= "`b"
            case "f": out .= "`f"
            case "n": out .= "`n"
            case "r": out .= "`r"
            case "t": out .= "`t"
            case "v": out .= "`v"
            default: out .= m3
        }
    }
    return out SubStr(Str, spo)
}