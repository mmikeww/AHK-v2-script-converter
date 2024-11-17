a := 1
b := 2
MsgBox %a%%b%
Swap(a, b)
MsgBox %a%%b%

Swap(ByRef Left, ByRef Right)
{
    temp := Left
    Left := Right
    Right := temp
}