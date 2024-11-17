var1 := "abc"
var2 := 123
MsgBox(Deref("%var1%def%var2%"))  ; Reports abcdef123.

Deref(Str)
{
    spo := 1
    out := ""
    while (fpo:=RegExMatch(Str, "(%(.*?)%)|``(.)", &m, (spo)<1 ? (spo)-1 : (spo)))
    {
        out .= SubStr(Str, (spo)<1 ? (spo)-1 : (spo), fpo-spo)
        spo := fpo + StrLen((m&&m[0]))
        if (m[1])
            out .= %m[2]%
        else Switch (m[3])
        {
            case "a":  out .= "`a"
            case "b":  out .= "`b"
            case "f":  out .= "`f"
            case "n":  out .= "`n"
            case "r":  out .= "`r"
            case "t":  out .= "`t"
            case "v":  out .= "`v"
            default:  out .= m[3]
        }
    }
    return out SubStr(Str, (spo)<1 ? (spo)-1 : (spo))
}