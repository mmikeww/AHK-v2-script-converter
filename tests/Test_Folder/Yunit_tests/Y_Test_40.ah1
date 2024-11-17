start = 2
count = 4
Source = Hello this is a test.
StringMid, out, Source, % start+5, % count
FileAppend, %out%, *