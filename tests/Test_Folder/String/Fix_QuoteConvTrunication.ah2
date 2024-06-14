; the following was being truncated after #147 implemented...
strPos := (strPos=="") ? this._curPos : strPos	; should remain unchanged
; but was being converted to the following after #147 implemented
; strPos := strPos==""

; the following are included to show they are still working
; ...after fix for above issue was implemented

; tests/Failed conversions/MsgBox_ex7.ah1
MsgBox("`"`"`"Hello World`"`"`"")
; v2
; MsgBox("`"`"`"Hello World`"`"`"")

; tests/Test_Folder/String/Assignment_ex1.ah1
str1 := "`"Hello World`""
str2 := "`"Hello World`""
str3 := "Hello `"test`" World"
MsgBox(str1 "`n`n" str2 "`n`n"  str3)
; v2
;str1 := "`"Hello World`""
;str2 := "`"Hello World`""
;str3 := "Hello `"test`" World"
;MsgBox(str1 "`n`n" str2 "`n`n"  str3)

; tests/Test_Folder/String/Assignment_ex2.ah1
hello := "Hello "
world := "World"
helloWorld := hello "`"test`" " world
MsgBox(hello world "`n" helloWorld)
; v2
;hello := "Hello "
;world := "World"
;helloWorld := hello "`"test`" " world
;MsgBox(hello world "`n" helloWorld)

; tests/Test_Folder/String/Assignment_ex3.ah1
the := "The "
quick := "quick "
fox := "fox "
over := "over "
lazy := "lazy "
str := the quick "`"brown`" " fox "`"jumped`" " over "`"the`" " lazy "dog"
MsgBox(str)
; v2
;the := "The "
;quick := "quick "
;fox := "fox "
;over := "over "
;lazy := "lazy "
;str := the quick "`"brown`" " fox "`"jumped`" " over "`"the`" " lazy "dog"
;MsgBox(str)

; tests/Test_Folder/String/Assignment_ex4.ah1
hello := "`"Hello`""
helloWorld := hello " World"
MsgBox(helloWorld)
; v2
;hello := "`"Hello`""
;helloWorld := hello " World"
;MsgBox(helloWorld)

; tests/Test_Folder/String/Assignment_ex5.ah1
Str := "`"Hello`" "
var := "`"Test`" "
Str .= var "`"World`""
MsgBox(Str)
; v2
;Str := "`"Hello`" "
;var := "`"Test`" "
;Str .= var "`"World`""
;MsgBox(Str)