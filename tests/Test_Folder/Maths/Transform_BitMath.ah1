Transform, _BitNotU, BitNot, 0xfffffffe ; Unsigned 32
Transform, _BitNotS, BitNot, -0xfffffffe ; Signed 64
Transform, _BitAnd, BitAnd, 0xcab, 0xfab
Transform, _BitOr, BitOr, 0xab0, 0xa0c
Transform, _BitXOr, BitXOr, 0xab0, 0xa0c
Transform, _BitShiftLeft, BitShiftLeft, 3, 2
Transform, _BitShiftRight, BitShiftRight, 3, 2

MsgBox, %_BitNotU%`n%_BitNotS%`n%_BitAnd%`n%_BitOr%`n%_BitXOr%`n%_BitShiftLeft%`n%_BitShiftRight%