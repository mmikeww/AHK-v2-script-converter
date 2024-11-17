x = +plus
StringTrimLeft x, x, 1           ; leading +x -> x
IfEqual, x, plus
   FileAppend, %x%, *