var := 1
Concat((var=5) ? 5 : 0)

Concat(one, two="2")
{
   FileAppend, % one + two, *
}