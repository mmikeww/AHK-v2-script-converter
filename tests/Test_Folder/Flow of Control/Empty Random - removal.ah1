
msgbox % Rand()

Rand( a=0.0, b=1 ) {
   IfEqual,a,,Random,,% r := b = 1 ? Rand(0,0xFFFFFFFF) : b
   Else Random,r,a,b
   Return r
}