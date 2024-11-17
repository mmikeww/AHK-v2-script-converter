Concat(5)

Concat(one, two="hello,world")
{
   FileAppend, % one . two, *
}