Concat("joe,says,")

Concat(one, two:="hello,world")
{
   FileAppend(one . two, "*")
}