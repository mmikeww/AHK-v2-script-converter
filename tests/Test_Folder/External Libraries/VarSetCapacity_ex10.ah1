; Calculate required buffer space for a string.
bytes_per_char := A_IsUnicode ? 2 : 1
max_chars := 500
max_bytes := max_chars * bytes_per_char

Loop 2
{
    ; Allocate space for use with DllCall.
    VarSetCapacity(buf, max_bytes)

    if (A_Index = 1)
        ; Alter the variable indirectly via DllCall.
        DllCall("wsprintf", "Ptr", &buf, "Str", "0x%08x", "UInt", 4919, "CDecl")
    else
        ; Use "str" to update the length automatically:
        DllCall("wsprintf", "Str", buf, "Str", "0x%08x", "UInt", 4919, "CDecl")

    ; Concatenate a string to demonstrate why the length needs to be updated:
    wrong_str := buf . "<end>"
    wrong_len := StrLen(buf)

    ; Update the variable's length.
    VarSetCapacity(buf, -1)

    right_str := buf . "<end>"
    right_len := StrLen(buf)

    Msg = Before updating`n
    Msg = %Msg%%A_Space%String: %wrong_str%`n
    Msg = %Msg%%A_Space%Length: %wrong_len%`n`n
    Msg = %Msg%After updating`n
    Msg = %Msg%%A_Space%String: %right_str%`n
    Msg = %Msg%%A_Space%Length: %right_len%`n
    MsgBox %Msg%
}

