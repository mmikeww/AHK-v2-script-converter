; https://github.com/mmikeww/AHK-v2-script-converter/issues/437

str = foobar
str = %str% :`n
(LTrim Join`s
    Is foo
    concatenated with
    bar
)
MsgBox % "[" str "]"

str2=
(
12345
)
str2=%str2%
(
67890
)
str2=%str2%
(
ABCDE
)
MsgBox % "[" str2 "]"