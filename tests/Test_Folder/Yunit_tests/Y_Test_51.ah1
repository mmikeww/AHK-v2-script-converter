var = 5
Concat((var=5) ? 5 : 0)

Concat(one, two="hello,world", three = 3, four = "does 2+2=4?")
{
   FileAppend, % one . two . three . four, *
}