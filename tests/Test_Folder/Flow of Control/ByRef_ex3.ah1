MyFunc(ByRef a, ByRef b) {}

MyFunc(a, b)
MyFunc(a, b), a = b ; Stripped
MyFunc(a, b) ; Stripped

; MyFunc(a, b), Ord(1)
; MyFunc(a, b), MyFunc(a, b)