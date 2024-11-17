; Initialize string to search.
Colors := "red,green|blue;yellow|cyan,magenta"
; Initialize counter to keep track of our position in the string.
Position := 0

Loop, Parse, Colors, `,|;
{
    ; Calculate the position of the delimiter at the end of this field.
    Position += StrLen(A_LoopField) + 1
    ; Retrieve the delimiter found by the parsing loop.
    Delimiter := SubStr(Colors, Position, 1)

    MsgBox Field: %A_LoopField%`nDelimiter: %Delimiter%
}