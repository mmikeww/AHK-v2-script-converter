; Calculate required buffer space for a string.
bytes_per_char := 1 ? 2 : 1
max_chars := 500
max_bytes := max_chars * bytes_per_char

Loop 2
{
    ; Allocate space for use with DllCall.
    VarSetStrCapacity(&buf, max_bytes) ; V1toV2: if 'buf' is NOT a UTF-16 string, use 'buf := Buffer(max_bytes)' and replace all instances of 'StrPtr(buf)' with 'buf.Ptr'

    if (A_Index = 1)
        ; Alter the variable indirectly via DllCall.
        DllCall("wsprintf", "Ptr", StrPtr(buf), "Str", "0x%08x", "UInt", 4919, "CDecl")
    else
        ; Use "str" to update the length automatically:
        DllCall("wsprintf", "Str", buf, "Str", "0x%08x", "UInt", 4919, "CDecl")

    ; Concatenate a string to demonstrate why the length needs to be updated:
    wrong_str := buf . "<end>"
    wrong_len := StrLen(buf)

    ; Update the variable's length.
    VarSetStrCapacity(&buf, -1) ; V1toV2: if 'buf' is NOT a UTF-16 string, use 'buf := Buffer(-1)' and replace all instances of 'StrPtr(buf)' with 'buf.Ptr'

    right_str := buf . "<end>"
    right_len := StrLen(buf)

    Msg := "Before updating`n"
    Msg := Msg . "" . A_Space . "String: " . wrong_str . "`n"
    Msg := Msg . "" . A_Space . "Length: " . wrong_len . "`n`n"
    Msg := Msg . "After updating`n"
    Msg := Msg . "" . A_Space . "String: " . right_str . "`n"
    Msg := Msg . "" . A_Space . "Length: " . right_len . "`n"
    MsgBox(Msg)
}

