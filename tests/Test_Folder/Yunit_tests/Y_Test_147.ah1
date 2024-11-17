Str = This is a test.
count := 3
StringTrimRight, OutputVar, Str, count+3
FileAppend, [%OutputVar%], *