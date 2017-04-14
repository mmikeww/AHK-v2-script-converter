#Include Yunit\Yunit.ahk
#Include Yunit\Window.ahk
#Include ..\ConvertFuncs.ahk
#Include ExecScript.ahk

Yunit.Use(YunitWindow).Test(ConvertTests, ToExpTests, ToStringExprTests
                          , RemoveSurroundingQuotes, RemoveSurroundingPercents, ExecScriptTests)


class ConvertTests
{
   Begin()
   {
   }

   AssignmentString()
   {
      ; we pipe the output of FileAppend to StdOutput
      ; then ExecScript() executes the script and reads from StdOut

      input_script := "
         (Join`r`n %
                                 var = hello
                                 msg = %var% world
                                 FileAppend, %msg%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hello"
                                 msg := var . " world"
                                 FileAppend, %msg%, *
         )"
      ; in v2 that could alternatively be:
      ; msg := "%var% world"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   AssignmentStringWithQuotes()
   {
      input_script := "
         (Join`r`n %
                                 msg = the man said, "hello"
                                 FileAppend, %msg%, *
         )"

      expected := "
         (Join`r`n %
                                 msg := "the man said, ``"hello``""
                                 FileAppend, %msg%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   AssignmentStringWithPreceedingSpaces()
   {
      input_script := "
         (Join`r`n %
                                 msg =    hello world   
                                 FileAppend, %msg%, *
         )"

      expected := "
         (Join`r`n %
                                 msg := "hello world"
                                 FileAppend, %msg%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   AssignmentNumber()
   {
      input_script := "
         (Join`r`n %
                                 var = 2
                                 if (var = 2)
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "2"
                                 if (var = 2)
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   CommentBlock()
   {
      input_script := "
         (Join`r`n %
                                 /`*
                                 var = hello
                                 *`/
                                 var2 = hello2
                                 FileAppend, var=%var%``nvar2=%var2%, *
         )"

      expected := "
         (Join`r`n %
                                 /`*
                                 var = hello
                                 *`/
                                 var2 := "hello2"
                                 FileAppend, var=%var%``nvar2=%var2%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   CommentBlock_ContinuationInside()
   {
      input_script := "
         (Join`r`n %
                                 /`*
                                 var = 
                                 `(
                                 blah blah
                                 `)
                                 *`/
                                 var2 = hello2
                                 FileAppend, var=%var%``nvar2=%var2%, *
         )"

      expected := "
         (Join`r`n %
                                 /`*
                                 var = 
                                 `(
                                 blah blah
                                 `)
                                 *`/
                                 var2 := "hello2"
                                 FileAppend, var=%var%``nvar2=%var2%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Continuation_Assignment()
   {
      input_script := "
         (Join`r`n %
                                 Sleep, 100
                                 var =
                                 `(
                                 line1
                                 line2
                                 `)
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 Sleep, 100
                                 var := "
                                 `(
                                 line1
                                 line2
                                 `)"
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Continuation_Assignment_indented()
   {
      input_script := "
         (Join`r`n %
                                 var =
                                    `(
                                    hello world
                                    `)
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "
                                    `(
                                    hello world
                                    `)"
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   /*
   Continuation_NewlinePreceding()
   {
      input_script := "
         (Join`r`n %
                                 var =

                                 `(
                                 hello
                                 `)
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "

                                 `(
                                 hello
                                 `)"
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }
   */

   Continuation_CommandParam()
   {
      input_script := "
         (Join`r`n %
                                 var := 9
                                 FileAppend, 
                                 `(
                                 %var%
                                 line2
                                 `), *
         )"

      expected := "
         (Join`r`n %
                                 var := 9
                                 FileAppend, 
                                 `(
                                 %var%
                                 line2
                                 `), *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Ternary_NotAContinuation()
   {
      input_script := "
         (Join`r`n %
                                 var := true
                                 ( var ) ? x : y
                                 var2 = value2
         )"

      expected := "
         (Join`r`n %
                                 var := true
                                 ( var ) ? x : y
                                 var2 := "value2"
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_EqualsString()
   {
      input_script := "
         (Join`r`n %
                                 var := "helloworld"
                                 if var = helloworld
                                    FileAppend, equal, *
         )"

      expected := "
         (Join`r`n %
                                 var := "helloworld"
                                 if (var = "helloworld")
                                    FileAppend, equal, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_NotEqualsEmptyString()
   {
      input_script := "
         (Join`r`n %
                                 var = 3
                                 if var != 
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3"
                                 if (var != "")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_EqualsInt()
   {
      input_script := "
         (Join`r`n %
                                 var = 8
                                 if var = 8
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "8"
                                 if (var = 8)
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_GreaterThanInt()
   {
      input_script := "
         (Join`r`n %
                                 var = 10
                                 if var > 8
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "10"
                                 if (var > 8)
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_EqualsVariable()
   {
      input_script := "
         (Join`r`n %
                                 MyVar = joe
                                 MyVar2 = joe
                                 if MyVar = %MyVar2%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
         )"

      expected := "
         (Join`r`n %
                                 MyVar := "joe"
                                 MyVar2 := "joe"
                                 if (MyVar = MyVar2)
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_Else()
   {
      input_script := "
         (Join`r`n %
                                 MyVar = joe
                                 MyVar2 = 
                                 if MyVar = %MyVar2%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
                                 else if MyVar =
                                     FileAppend, MyVar is empty/blank, *
         )"

      expected := "
         (Join`r`n %
                                 MyVar := "joe"
                                 MyVar2 := ""
                                 if (MyVar = MyVar2)
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
                                 else if (MyVar = "")
                                     FileAppend, MyVar is empty/blank, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Traditional_If_Else_NotEquals()
   {
      input_script := "
         (Join`r`n %
                                 MyVar = joe
                                 MyVar2 = joe2
                                 if MyVar = %MyVar2%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
                                 else if MyVar <>
                                     FileAppend, MyVar is not empty/blank, *
         )"

      expected := "
         (Join`r`n %
                                 MyVar := "joe"
                                 MyVar2 := "joe2"
                                 if (MyVar = MyVar2)
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
                                 else if (MyVar <> "")
                                     FileAppend, MyVar is not empty/blank, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Expression_If_Function()
   {
      input_script := "
         (Join`r`n %
                                 if MyFunc()
                                    FileAppend, %var%, *

                                 MyFunc() {
                                    global var := 777
                                    return true
                                 }
         )"

      expected := "
         (Join`r`n %
                                 if MyFunc()
                                    FileAppend, %var%, *

                                 MyFunc() {
                                    global var := 777
                                    return true
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Expression_If_Not()
   {
      input_script := "
         (Join`r`n %
                                 var := ""
                                 if not var = 
                                    FileAppend, var is not empty, *
                                 else
                                    FileAppend, var is empty, *
         )"

      expected := "
         (Join`r`n %
                                 var := ""
                                 if not (var = "")
                                    FileAppend, var is not empty, *
                                 else
                                    FileAppend, var is empty, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Expression_If_NoSpaceBeforeParen()
   {
      input_script := "
         (Join`r`n %
                                 method := 1
                                 if( method = 1 )
                                    FileAppend, %method%, *
         )"

      expected := "
         (Join`r`n %
                                 method := 1
                                 if( method = 1 )
                                    FileAppend, %method%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   While_NoSpaceBeforeParen()
   {
      input_script := "
         (Join`r`n %
                                 method := 0
                                 while( method = 1 )
                                    break
                                 FileAppend, %method%, *
         )"

      expected := "
         (Join`r`n %
                                 method := 0
                                 while( method = 1 )
                                    break
                                 FileAppend, %method%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_CommandThenComma()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfEqual, var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_CommandThenSpace()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfEqual var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_SameLineAction()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfEqual var, value, FileGetSize, size, %A_ScriptDir%\Tests.ahk
                                 FileAppend, %size%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value"), FileGetSize, size, %A_ScriptDir%\Tests.ahk
                                 FileAppend, %size%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_CommandThenMultipleSpaces()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfEqual    var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_LeadingSpacesInParam()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfEqual, var,     value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_EscapedComma()
   {
      input_script := "
         (Join`r`n %
                                 var = ,
                                 IfEqual, var, `,
                                    FileAppend, var is a comma, *
         )"

      expected := "
         (Join`r`n %
                                 var := ","
                                 if (var = ",")
                                    FileAppend, var is a comma, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_EscapedCommaMidString()
   {
      input_script := "
         (Join`r`n %
                                 var = hello,world
                                 IfEqual, var, hello`,world
                                    FileAppend, var matches, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hello,world"
                                 if (var = "hello,world")
                                    FileAppend, var matches, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }
/*
THESE FOLLOWING TWO TESTS DON'T WORK
FOR THE IFCOMMANDS THAT ALLOW A SAME LINE ACTION.
WE INSTEAD GIVE PRECEDENCE TO THE SAME LINE ACTION
AND THEREFORE CANNOT SUPPORT THE UNESCAPED COMMAS.
I THINK THE ONLY WAY TO SUPPORT BOTH WOULD BE TO CHECK IF
THE NEXT WORD AFTER THE COMMA IS A COMMAND NAME
WHICH WOULD MEAN WE'D NEED THE FULL COMMAND LIST.

   IfEqual_EscapedCommaNotNeededInLastParam()
   {
      ; "Commas that appear within the last parameter of a command do not need to be escaped because 
      ;  the program knows to treat them literally."
      ;
      ; from:   https://autohotkey.com/docs/commands/_EscapeChar.htm

      input_script := "
         (Join`r`n %
                                 var = ,
                                 IfEqual, var, ,
                                    FileAppend, var is a comma, *
         )"

      expected := "
         (Join`r`n %
                                 var := ","
                                 if (var = ",")
                                    FileAppend, var is a comma, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfEqual_EscapedCommaNotNeededMidString()
   {
      ; "Commas that appear within the last parameter of a command do not need to be escaped because 
      ;  the program knows to treat them literally."
      ;
      ; from:   https://autohotkey.com/docs/commands/_EscapeChar.htm

      input_script := "
         (Join`r`n %
                                 var = hello,world
                                 IfEqual, var, hello,world
                                    FileAppend, var matches, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hello,world"
                                 if (var = "hello,world")
                                    FileAppend, var matches, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }
*/
   IfNotEqual()
   {
      input_script := "
         (Join`r`n %
                                 var = val
                                 IfNotEqual, var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "val"
                                 if (var != "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfGreaterOrEqual()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfGreaterOrEqual, var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var >= "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfGreater()
   {
      input_script := "
         (Join`r`n %
                                 var = zzz
                                 IfGreater, var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "zzz"
                                 if (var > "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfLess()
   {
      input_script := "
         (Join`r`n %
                                 var = hhh
                                 IfLess, var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hhh"
                                 if (var < "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfLessOrEqual()
   {
      input_script := "
         (Join`r`n %
                                 var = hhh
                                 IfLessOrEqual, var, value
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hhh"
                                 if (var <= "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvMult()
   {
      input_script := "
         (Join`r`n %
                                 var = 3
                                 EnvMult, var, 5
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3"
                                 var *= 5
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvMult_ExpressionParam()
   {
      input_script := "
         (Join`r`n %
                                 var = 1
                                 var2 = 2
                                 EnvMult, var, var2
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "1"
                                 var2 := "2"
                                 var *= var2
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvAdd()
   {
      input_script := "
         (Join`r`n %
                                 var = 1
                                 EnvAdd, var, 2
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "1"
                                 var += 2
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvAdd_time()
   {
      input_script := "
         (Join`r`n %
                                 var = %A_Now%
                                 EnvAdd, var, 7, days
                                 FormatTime, var, %var%, ShortDate
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := A_Now
                                 var := DateAdd(var, 7, "days")
                                 FormatTime, var, %var%, ShortDate
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvAdd_var()
   {
      input_script := "
         (Join`r`n %
                                 var = 4
                                 two := 2
                                 EnvAdd, var, two
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "4"
                                 two := 2
                                 var += two
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvAdd_var_forcedexpr()
   {
      input_script := "
         (Join`r`n %
                                 var = 4
                                 two := 2
                                 EnvAdd, var, % two
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "4"
                                 two := 2
                                 var += two
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvSub()
   {
      input_script := "
         (Join`r`n %
                                 var = 5
                                 EnvSub, var, 2
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "5"
                                 var -= 2
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvSub_time()
   {
      input_script := "
         (Join`r`n %
                                 var1 = 20050126
                                 var2 = 20040126
                                 EnvSub, var1, %var2%, days
                                 FileAppend, %var1%, *
         )"

      expected := "
         (Join`r`n %
                                 var1 := "20050126"
                                 var2 := "20040126"
                                 var1 := DateDiff(var1, var2, "days")
                                 FileAppend, %var1%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvSub_ExpressionValue()
   {
      input_script := "
         (Join`r`n %
                                 var = 9
                                 value = 6
                                 EnvSub, var, value
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "9"
                                 value := "6"
                                 var -= value
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues()
   {
      input_script := "
         (Join`r`n %
                                 five := MyFunc()
                                 FileAppend, %five%, *
                                 MyFunc(var=5) {
                                    return var
                                 }
         )"

      expected := "
         (Join`r`n %
                                 five := MyFunc()
                                 FileAppend, %five%, *
                                 MyFunc(var:=5) {
                                    return var
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues_OTB()
   {
      input_script := "
         (Join`r`n %
                                 five := MyFunc()
                                 FileAppend, %five%, *
                                 MyFunc(var=5) {
                                    return var
                                 }
         )"

      expected := "
         (Join`r`n %
                                 five := MyFunc()
                                 FileAppend, %five%, *
                                 MyFunc(var:=5) {
                                    return var
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues_CommasInParamString()
   {
      input_script := "
         (Join`r`n %
                                 Concat(5)

                                 Concat(one, two="hello,world")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"

      expected := "
         (Join`r`n %
                                 Concat(5)

                                 Concat(one, two:="hello,world")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues_CommasInCallString()
   {
      input_script := "
         (Join`r`n %
                                 Concat("joe,says,")

                                 Concat(one, two="hello,world")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"

      expected := "
         (Join`r`n %
                                 Concat("joe,says,")

                                 Concat(one, two:="hello,world")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues_EqualSignInString()
   {
      input_script := "
         (Join`r`n %
                                 Concat(5)

                                 Concat(one, two="+5=10")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"

      expected := "
         (Join`r`n %
                                 Concat(5)

                                 Concat(one, two:="+5=10")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues_TernaryInCall()
   {
      ; dont replace the equal sign in the ternary during the function CALL
      input_script := "
         (Join`r`n %
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two="2")
                                 {
                                    FileAppend, % one + two, *
                                 }
         )"

      expected := "
         (Join`r`n %
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two:="2")
                                 {
                                    FileAppend, % one + two, *
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FunctionDefaultParamValues_WholeShebang()
   {
      input_script := "
         (Join`r`n %
                                 var = 5
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two="hello,world", three = 3, four = "does 2+2=4?")
                                 {
                                    FileAppend, % one . two . three . four, *
                                 }
         )"

      expected := "
         (Join`r`n %
                                 var := "5"
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two:="hello,world", three := 3, four := "does 2+2=4?")
                                 {
                                    FileAppend, % one . two . three . four, *
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   NoEnv_Remove()
   {
      input_script := "
         (Join`r`n %
                                 #NoEnv
                                 FileAppend, hi, *
         )"

      expected := "
         (Join`r`n %
                                 ; REMOVED: #NoEnv
                                 FileAppend, hi, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   SetFormat_Remove()
   {
      input_script := "
         (Join`r`n %
                                 SetFormat, integerfast, H
                                 FileAppend, hi, *
         )"

      expected := "
         (Join`r`n %
                                 ; REMOVED: SetFormat, integerfast, H
                                 FileAppend, hi, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   DriveGetFreeSpace()
   {
      input_script := "
         (Join`r`n %
                                 DriveSpaceFree, FreeSpace, c:\
                                 FileAppend, %FreeSpace%, *
         )"

      expected := "
         (Join`r`n %
                                 DriveGet, FreeSpace, SpaceFree, c:\
                                 FileAppend, %FreeSpace%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringUpper()
   {
      input_script := "
         (Join`r`n %
                                 var = Chris Mallet
                                 StringUpper, newvar, var
                                 FileAppend, %newvar%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "Chris Mallet"
                                 StrUpper, newvar, %var%
                                 FileAppend, %newvar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringLower()
   {
      input_script := "
         (Join`r`n %
                                 var = chris mallet
                                 StringLower, newvar, var, T
                                 if (newvar == "Chris Mallet")
                                    FileAppend, it worked, *
         )"

      expected := "
         (Join`r`n %
                                 var := "chris mallet"
                                 StrLower, newvar, %var%, T
                                 if (newvar == "Chris Mallet")
                                    FileAppend, it worked, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringLen()
   {
      input_script := "
         (Join`r`n %
                                 InputVar := "The Quick Brown Fox Jumps Over the Lazy Dog"
                                 StringLen, length, InputVar
                                 FileAppend, The length of InputVar is %length%., *
         )"

      expected := "
         (Join`r`n %
                                 InputVar := "The Quick Brown Fox Jumps Over the Lazy Dog"
                                 length := StrLen(InputVar)
                                 FileAppend, The length of InputVar is %length%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 Needle = def
                                 StringGetPos, pos, Haystack, %Needle%
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 Needle := "def"
                                 pos := InStr(Haystack, Needle) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_LiteralText()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 StringGetPos, pos, Haystack, def
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 pos := InStr(Haystack, "def") - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_SearchLeftOccurance()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = def
                                 StringGetPos, pos, Haystack, %Needle%, L2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "def"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (0)+1, 2) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_SearchLeftOccurance_StringCaseSense()
   {
      input_script := "
         (Join`r`n %
                                 StringCaseSense, on
                                 Haystack = abcdefabcdef
                                 Needle = DEF
                                 StringGetPos, pos, Haystack, %Needle%, L2
                                 FileAppend, The string was found at position %pos%, *
         )"

      expected := "
         (Join`r`n %
                                 StringCaseSense, on
                                 Haystack := "abcdefabcdef"
                                 Needle := "DEF"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (0)+1, 2) - 1
                                 FileAppend, The string was found at position %pos%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_SearchRight()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = bcd
                                 StringGetPos, pos, Haystack, %Needle%, R
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "bcd"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, -1*((0)+1), 1) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_SearchRightOccurance()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, R2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, -1*((0)+1), 2) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetLeft()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%,, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (4)+1, 1) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetLeftVariable()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 var = 2
                                 StringGetPos, pos, Haystack, %Needle%,, %var%
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 var := "2"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (var)+1, 1) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetLeftExpressionVariable()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 var = 1
                                 StringGetPos, pos, Haystack, %Needle%,, var+2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 var := "1"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (var+2)+1, 1) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetRightExpressionVariableOccurences()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdefabcdef
                                 Needle = cde
                                 var = 0
                                 StringGetPos, pos, Haystack, %Needle%, R2, var+2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdefabcdef"
                                 Needle := "cde"
                                 var := "0"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, -1*((var+2)+1), 2) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetLeftOccurence()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, L2, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (4)+1, 2) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetRight()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, R, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, -1*((4)+1), 1) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_OffsetRightOccurence()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, r2, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, -1*((4)+1), 2) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringGetPos_Duplicates()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = FFFF
                                 Needle = FF
                                 StringGetPos, pos, Haystack, %Needle%, L2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "FFFF"
                                 Needle := "FF"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (0)+1, 2) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringMid()
   {
      input_script := "
         (Join`r`n %
                                 Source = Hello this is a test. 
                                 StringMid, out, Source, 7
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 Source := "Hello this is a test." 
                                 out := SubStr(Source, 7)
                                 FileAppend, %out%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringMid_Count()
   {
      input_script := "
         (Join`r`n %
                                 Source = Hello this is a test. 
                                 StringMid, out, Source, 7, 4
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 Source := "Hello this is a test." 
                                 out := SubStr(Source, 7, 4)
                                 FileAppend, %out%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringMid_CountStartVar()
   {
      input_script := "
         (Join`r`n %
                                 start = 7
                                 Source = Hello this is a test. 
                                 StringMid, out, Source, %start%, 4
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 start := "7"
                                 Source := "Hello this is a test." 
                                 out := SubStr(Source, start, 4)
                                 FileAppend, %out%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringMid_StartAndCountExpressions()
   {
      input_script := "
         (Join`r`n %
                                 start = 2
                                 count = 4
                                 Source = Hello this is a test. 
                                 StringMid, out, Source, start+5, count
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 start := "2"
                                 count := "4"
                                 Source := "Hello this is a test." 
                                 out := SubStr(Source, start+5, count)
                                 FileAppend, %out%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringMid_Count_L()
   {
      input_script := "
         (Join`r`n %
                                 InputVar = The Red Fox
                                 StringMid, out, InputVar, 7, 3, L
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 InputVar := "The Red Fox"
                                 out := SubStr(SubStr(InputVar, 1, 7), -3)
                                 FileAppend, %out%, *
         )"

                                 ; or two lines:
                                 ;out := SubStr(InputVar, 1, 7)
                                 ;out := SubStr(out, -3)

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringMid_Count_L_expression()
   {
      input_script := "
         (Join`r`n %
                                 InputVar = The Red Fox
                                 left = LOL
                                 StringMid, out, InputVar, 7, 3, %left%
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 InputVar := "The Red Fox"
                                 left := "LOL"
                                 if (SubStr(left, 1, 1) = "L")
                                     out := SubStr(SubStr(InputVar, 1, 7), -3)
                                 else
                                     out := SubStr(InputVar, 7, 3)
                                 FileAppend, %out%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringLeft()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 StringLeft, OutputVar, String, 4
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 OutputVar := SubStr(String, 1, 4)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringLeft_CountExpr()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 3
                                 StringLeft, OutputVar, String, count+1
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 3
                                 OutputVar := SubStr(String, 1, count+1)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringRight()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 StringRight, OutputVar, String, 5
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 OutputVar := SubStr(String, -1*(5))
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringRight_CountExpr()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 6
                                 StringRight, OutputVar, String, count-1
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 6
                                 OutputVar := SubStr(String, -1*(count-1))
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringTrimLeft()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 StringTrimLeft, OutputVar, String, 5
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 OutputVar := SubStr(String, (5)+1)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringTrimLeft_CountExpr()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 5
                                 StringTrimLeft, OutputVar, String, count*1
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 5
                                 OutputVar := SubStr(String, (count*1)+1)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v0(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringTrimRight()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 StringTrimRight, OutputVar, String, 6
                                 FileAppend, [%OutputVar%], *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 OutputVar := SubStr(String, 1, -1*(6))
                                 FileAppend, [%OutputVar%], *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringTrimRight_CountExpr()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 3
                                 StringTrimRight, OutputVar, String, count+3
                                 FileAppend, [%OutputVar%], *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 3
                                 OutputVar := SubStr(String, 1, -1*(count+3))
                                 FileAppend, [%OutputVar%], *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Preserve_Indentation()
   {
      ; dont use LTrim and instead rely on AHK v2 default smart LTrim
      input_script := "
         (Join`r`n %
                                 if (1) {
                                    var = val
                                    if var = hello
                                 		MsgBox, this line starts with 2 tab characters
                                    else {
                                       ifequal, var, val
                                          StringGetPos, pos, var, al
                                    }
                                 }
                                 FileAppend, pos=%pos%, *
         )"

      expected := "
         (Join`r`n %
                                 if (1) {
                                    var := "val"
                                    if (var = "hello")
                                 		MsgBox, this line starts with 2 tab characters
                                    else {
                                       if (var = "val")
                                          pos := InStr(var, "al") - 1
                                    }
                                 }
                                 FileAppend, pos=%pos%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   WinGetActiveTitle()
   {
      input_script := "
         (Join`r`n %
                                 WinGetActiveTitle, OutputVar
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 WinGetTitle, OutputVar, A
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   WinGetActiveStats()
   {
      input_script := "
         (Join`r`n %
                                 WinGetActiveStats, title, w, h, x, y
                                 FileAppend, %title%-%w%-%h%-%x%-%y%, *
         )"

      expected := "
         (Join`r`n %
                                 WinGetTitle, title, A
                                 WinGetPos, x, y, w, h, A
                                 FileAppend, %title%-%w%-%h%-%x%-%y%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_Assignment()
   {
      input_script := "
         (Join`r`n %
                                 var = value     ; comment after 5 spaces
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"     ; comment after 5 spaces
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_TraditionalIf()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 if var = value     ; comment after 5 spaces
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value")     ; comment after 5 spaces
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_EnvAdd()
   {
      input_script := "
         (Join`r`n %
                                 var = 1
                                 EnvAdd, var, 2     ; comment after 5 spaces
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "1"
                                 var += 2     ; comment after 5 spaces
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_IfEqual()
   {
      input_script := "
         (Join`r`n %
                                 var = 1
                                 IfEqual, var, 1     ; comment after 5 spaces
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "1"
                                 if (var = 1)     ; comment after 5 spaces
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_SkippedLines()
   {
      input_script := "
         (Join`r`n %
                                 var = 1
                                    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
         )"

      expected := "
         (Join`r`n %
                                 var := "1"
                                 ; REMOVED:    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_StringTrimLeft()
   {
      input_script := "
         (Join`r`n %
                                 x = +plus
                                 StringTrimLeft x, x, 1           ; leading +x -> x
                                 IfEqual, x, plus
                                    FileAppend, %x%, *
         )"

      expected := "
         (Join`r`n %
                                 x := "+plus"
                                 x := SubStr(x, (1)+1)           ; leading +x -> x
                                 if (x = "plus")
                                    FileAppend, %x%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   PreserveComment_UntouchedLines()
   {
      input_script := "
         (Join`r`n %
                                 var := "value"     ; this line won't be changed by the converter
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"     ; this line won't be changed by the converter
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   /*
   AutoTrim()
   {
      input_script := "
         (Join`r`n %
                                 var := " helloworld "
                                 var2 = %var%
                                 FileAppend, %var2%, *
         )"

      expected := "
         (Join`r`n %
                                 var := " helloworld "
                                 var2 := Trim(var)
                                 FileAppend, %var2%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }
   */

   ReturnDeref()
   {
      input_script := "
         (Join`r`n %
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return %var%
                                 }
         )"

      expected := "
         (Join`r`n %
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return var
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ReturnNoDeref()
   {
      input_script := "
         (Join`r`n %
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return var . hi . (1+1) ; with comment
                                 }
         )"

      expected := "
         (Join`r`n %
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return var . hi . (1+1) ; with comment
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ReturnNoDerefFuncCall()
   {
      input_script := "
         (Join`r`n %
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    return OtherFunc(var, "world", 3)
                                 }
         )"

      expected := "
         (Join`r`n %
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    return OtherFunc(var, "world", 3)
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfVarIsType()
   {
      input_script := "
         (Join`r`n %
                                 var = 3.1415
                                 if var is float
                                    FileAppend, %var% is float, *
                                 else if var is integer
                                    FileAppend, %var% is int, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3.1415"
                                 if (var is "float")
                                    FileAppend, %var% is float, *
                                 else if (var is "integer")
                                    FileAppend, %var% is int, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfVarIsType_Deref()
   {
      input_script := "
         (Join`r`n %
                                 var = 3.1415
                                 type = float
                                 if var is %type%
                                    FileAppend, %var% is float, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3.1415"
                                 type := "float"
                                 if (var is type)
                                    FileAppend, %var% is float, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfVarIsTypeNot()
   {
      input_script := "
         (Join`r`n %
                                 var = 3.1415
                                 if var is not float
                                    FileAppend, %var% is not float, *
                                 else if var is not integer
                                    FileAppend, %var% is not int, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3.1415"
                                 if !(var is "float")
                                    FileAppend, %var% is not float, *
                                 else if !(var is "integer")
                                    FileAppend, %var% is not int, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfVarIsType_AIsUnicode()
   {
      input_script := "
         (Join`r`n %
                                 if A_IsUnicode
                                    FileAppend, AHK Unicode %A_IsUnicode%, *
         )"

      expected := "
         (Join`r`n %
                                 if A_IsUnicode
                                    FileAppend, AHK Unicode %A_IsUnicode%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringReplace()
   {
      input_script := "
         (Join`r`n %
                                 OldStr := "The_quick_brown_fox"
                                 StringReplace, NewStr, OldStr, _
                                 FileAppend, %NewStr%, *
         )"

      expected := "
         (Join`r`n %
                                 OldStr := "The_quick_brown_fox"
                                 StrReplace, NewStr, %OldStr%, _,,, 1
                                 FileAppend, %NewStr%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringReplace_One()
   {
      input_script := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%, +
                                 FileAppend, %NewStr%, *
         )"

      expected := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StrReplace, NewStr, %OldStr%, %A_Space%, +,, 1
                                 FileAppend, %NewStr%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringReplace_All()
   {
      input_script := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%, +, All
                                 FileAppend, %NewStr%, *
         )"

      expected := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StrReplace, NewStr, %OldStr%, %A_Space%, +
                                 FileAppend, %NewStr%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   StringReplace_UseErrorLevel()
   {
      input_script := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%, +, UseErrorLevel
                                 FileAppend, number of replacements: %ErrorLevel%, *
         )"

      expected := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StrReplace, NewStr, %OldStr%, %A_Space%, +, ErrorLevel
                                 FileAppend, number of replacements: %ErrorLevel%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_StringLeft_CountExpr()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 3
                                 StringLeft, OutputVar, String, % count+1
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 3
                                 OutputVar := SubStr(String, 1, count+1)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_StringReplace_All()
   {
      input_script := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, % " ", % "+", All
                                 FileAppend, %NewStr%, *
         )"

      expected := "
         (Join`r`n %
                                 OldStr := "The quick brown fox"
                                 StrReplace, NewStr, %OldStr%, % " ", % "+"
                                 FileAppend, %NewStr%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_StringMid_StartAndCountExpressions()
   {
      input_script := "
         (Join`r`n %
                                 start = 2
                                 count = 4
                                 Source = Hello this is a test. 
                                 StringMid, out, Source, % start+5, % count
                                 FileAppend, %out%, *
         )"

      expected := "
         (Join`r`n %
                                 start := "2"
                                 count := "4"
                                 Source := "Hello this is a test." 
                                 out := SubStr(Source, start+5, count)
                                 FileAppend, %out%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_StringGetPos_OffsetLeftExpressionVariable()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 var = 1
                                 StringGetPos, pos, Haystack, %Needle%,, % var+2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 var := "1"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (var+2)+1, 1) - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_StringGetPos_LiteralText()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 StringGetPos, pos, Haystack, % "def"
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 pos := InStr(Haystack, "def") - 1
                                 if (pos >= 0)
                                     FileAppend, The string was found at position %pos%., *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_IfEqual_CommandThenComma()
   {
      input_script := "
         (Join`r`n %
                                 var = value
                                 IfEqual, var, % "value"
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "value"
                                 if (var = "value")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   ForcedExpression_Traditional_If_GreaterThanInt()
   {
      input_script := "
         (Join`r`n %
                                 var = 10
                                 if var > % 4*2
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "10"
                                 if (var > 4*2)
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   CBE2E_var()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 7
                                 StringLeft, OutputVar, String, count
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 7
                                 OutputVar := SubStr(String, 1, count)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   CBE2E_var_deref()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 7
                                 StringLeft, OutputVar, String, %count%
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 7
                                 OutputVar := SubStr(String, 1, count)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   CBE2E_var_forcedexpr()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 7
                                 StringLeft, OutputVar, String, % count
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 7
                                 OutputVar := SubStr(String, 1, count)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   CBE2E_var_forcedexpr_doublederef()
   {
      input_script := "
         (Join`r`n %
                                 String = This is a test.
                                 count := 7
                                 two_letters := "nt"
                                 StringLeft, OutputVar, String, % cou%two_letters%
                                 FileAppend, %OutputVar%, *
         )"

      expected := "
         (Join`r`n %
                                 String := "This is a test."
                                 count := 7
                                 two_letters := "nt"
                                 OutputVar := SubStr(String, 1, cou%two_letters%)
                                 FileAppend, %OutputVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Sleep()
   {
      input_script := "
         (Join`r`n %
                                 Sleep, 500
         )"

      expected := "
         (Join`r`n %
                                 Sleep, 500
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Sleep_CBE2T_varexpr()
   {
      input_script := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, half_second
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      expected := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, %half_second%
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Sleep_CBE2T_var()
   {
      input_script := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, %half_second%
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      expected := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, %half_second%
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Sleep_CBE2T_expr()
   {
      input_script := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, half_second*2
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      expected := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, %half_second*2%
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Sleep_CBE2T_exprforced()
   {
      input_script := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, % half_second*2
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      expected := "
         (Join`r`n %
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, % half_second*2
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EnvUpdate()
   {
      input_script := "
         (Join`r`n %
                           EnvUpdate
         )"

      expected := "
         (Join`r`n %
                           SendMessage, % WM_SETTINGCHANGE := 0x001A, 0, Environment,, % "ahk_id " . HWND_BROADCAST := "0xFFFF"
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   SetEnv()
   {
      input_script := "
         (Join`r`n %
                                 SetEnv, var, hello
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hello"
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   SetEnv_UnescapedCommasInLastParam()
   {
      input_script := "
         (Join`r`n %
                                 SetEnv, var, h,e, l,l,o
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "h,e, l,l,o"
                                 FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   TooFewParams()
   {
      input_script := "
         (Join`r`n %
                                 var := "helloooo"
                                 IfNotEqual, var
                                    FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "helloooo"
                                 if (var != "")
                                    FileAppend, %var%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfInString_var()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 Needle = abc
                                 IfInString, Haystack, %Needle%
                                    FileAppend, found, *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 Needle := "abc"
                                 if InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false)
                                    FileAppend, found, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfInString_text()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 IfInString, Haystack, jklm
                                    FileAppend, found, *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 if InStr(Haystack, "jklm", (A_StringCaseSense="On") ? true : false)
                                    FileAppend, found, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfInString_SameLineAction()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = z.y.x.w
                                 IfInString, Haystack, y.x, SysGet, mouse_btns, 43
                                 FileAppend, %mouse_btns%, *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "z.y.x.w"
                                 if InStr(Haystack, "y.x", (A_StringCaseSense="On") ? true : false), SysGet, mouse_btns, 43
                                 FileAppend, %mouse_btns%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfInString_block()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 IfInString, Haystack, jklm
                                 {
                                    Sleep, 10
                                    FileAppend, found, *
                                 }
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 if InStr(Haystack, "jklm", (A_StringCaseSense="On") ? true : false)
                                 {
                                    Sleep, 10
                                    FileAppend, found, *
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfNotInString_text()
   {
      input_script := "
         (Join`r`n %
                                 Haystack = abcdefghijklmnopqrs
                                 IfNotInString, Haystack, jklm
                                    FileAppend, found, *
         )"

      expected := "
         (Join`r`n %
                                 Haystack := "abcdefghijklmnopqrs"
                                 if !InStr(Haystack, "jklm", (A_StringCaseSense="On") ? true : false)
                                    FileAppend, found, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfExist()
   {
      input_script := "
         (Join`r`n %
                                 IfExist, C:\
                                    FileAppend, the drive exists, *
         )"

      expected := "
         (Join`r`n %
                                 if FileExist("C:\")
                                    FileAppend, the drive exists, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfNotExist()
   {
      input_script := "
         (Join`r`n %
                                 IfNotExist, W:\
                                    FileAppend, the drive doesn't exist, *
         )"

      expected := "
         (Join`r`n %
                                 if !FileExist("W:\")
                                    FileAppend, the drive doesn't exist, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfWinExist()
   {
      input_script := "
         (Join`r`n %
                                 IfWinExist, ahk_class Notepad
                                    FileAppend, notepad is open, *
                                 else
                                    FileAppend, notepad is not open, *
         )"

      expected := "
         (Join`r`n %
                                 if WinExist("ahk_class Notepad", "", "", "")
                                    FileAppend, notepad is open, *
                                 else
                                    FileAppend, notepad is not open, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfWinNotExist()
   {
      input_script := "
         (Join`r`n %
                                 IfWinNotExist, ahk_class Notepad
                                    FileAppend, notepad is not open, *
                                 else
                                    FileAppend, notepad is open, *
         )"

      expected := "
         (Join`r`n %
                                 if !WinExist("ahk_class Notepad", "", "", "")
                                    FileAppend, notepad is not open, *
                                 else
                                    FileAppend, notepad is open, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfWinActive()
   {
      input_script := "
         (Join`r`n %
                                 IfWinActive, ahk_class Notepad
                                    FileAppend, notepad is Active, *
                                 else
                                    FileAppend, notepad is not Active, *
         )"

      expected := "
         (Join`r`n %
                                 if WinActive("ahk_class Notepad", "", "", "")
                                    FileAppend, notepad is Active, *
                                 else
                                    FileAppend, notepad is not Active, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfWinActive_emptyparams()
   {
      input_script := "
         (Join`r`n %
                                 IfWinActive
                                    FileAppend, last found window is Active, *
                                 else
                                    FileAppend, last found window is not Active, *
         )"

      expected := "
         (Join`r`n %
                                 if WinActive("", "", "", "")
                                    FileAppend, last found window is Active, *
                                 else
                                    FileAppend, last found window is not Active, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfWinNotActive()
   {
      input_script := "
         (Join`r`n %
                                 IfWinNotActive, ahk_class Notepad
                                    FileAppend, notepad is not Active, *
                                 else
                                    FileAppend, notepad is Active, *
         )"

      expected := "
         (Join`r`n %
                                 if !WinActive("ahk_class Notepad", "", "", "")
                                    FileAppend, notepad is not Active, *
                                 else
                                    FileAppend, notepad is Active, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FileCopyDir()
   {
      input_script := "
         (Join`r`n %
                                 FileCopyDir, C:\My Folder, C:\Copy of My Folder
                                 FileCopyDir, C:\My Folder, C:\Copy of My Folder, 0
         )"

      expected := "
         (Join`r`n %
                                 DirCopy, C:\My Folder, C:\Copy of My Folder
                                 DirCopy, C:\My Folder, C:\Copy of My Folder, 0
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FileCreateDir()
   {
      input_script := "
         (Join`r`n %
                                 FileCreateDir, C:\My Folder
         )"

      expected := "
         (Join`r`n %
                                 DirCreate, C:\My Folder
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FileMoveDir()
   {
      input_script := "
         (Join`r`n %
                                 FileMoveDir, C:\My Folder, C:\Copy of My Folder
                                 FileMoveDir, C:\My Folder, C:\Copy of My Folder, 0
         )"

      expected := "
         (Join`r`n %
                                 DirMove, C:\My Folder, C:\Copy of My Folder
                                 DirMove, C:\My Folder, C:\Copy of My Folder, 0
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FileRemoveDir()
   {
      input_script := "
         (Join`r`n %
                                 FileRemoveDir, C:\My Folder
                                 FileRemoveDir, C:\My Folder, 0
         )"

      expected := "
         (Join`r`n %
                                 DirDelete, C:\My Folder
                                 DirDelete, C:\My Folder, 0
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FileSelectFolder()
   {
      input_script := "
         (Join`r`n %
                                 FileSelectFolder, outputvar
                                 FileSelectFolder, outputvar, C:\
                                 FileSelectFolder, outputvar, , 3
         )"

      expected := "
         (Join`r`n %
                                 DirSelect, outputvar
                                 DirSelect, outputvar, C:\
                                 DirSelect, outputvar, , 3
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   FileSelectFile()
   {
      input_script := "
         (Join`r`n %
                                 FileSelectFile, outputvar
                                 FileSelectFile, SelectedFile, 3, , Open a file, Text Documents (*.txt`; *.doc)
         )"

      expected := "
         (Join`r`n %
                                 FileSelect, outputvar
                                 FileSelect, SelectedFile, 3, , Open a file, Text Documents (*.txt`; *.doc)
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfBetween()
   {
      input_script := "
         (Join`r`n %
                                 var = 3.1415
                                 if var between 5 and 10
                                    FileAppend, %var% between 5 and 10, *
                                 else if var between 1 and 4
                                    FileAppend, %var% between 1 and 4, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3.1415"
                                 if (var >= 5 && var <= 10)
                                    FileAppend, %var% between 5 and 10, *
                                 else if (var >= 1 && var <= 4)
                                    FileAppend, %var% between 1 and 4, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfBetweenNot()
   {
      input_script := "
         (Join`r`n %
                                 var = 3.1415
                                 if var not between 0.0 and 1.0
                                    FileAppend, %var% not between 0.0 and 1.0, *
                                 else if var not between 1 and 4
                                    FileAppend, %var% not between 1 and 4, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3.1415"
                                 if !(var >= 0.0 && var <= 1.0)
                                    FileAppend, %var% not between 0.0 and 1.0, *
                                 else if !(var >= 1 && var <= 4)
                                    FileAppend, %var% not between 1 and 4, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfBetweenVars()
   {
      input_script := "
         (Join`r`n %
                                 var = 3.1415
                                 varLow = 2
                                 varHigh = 4
                                 if var between %VarLow% and %VarHigh%
                                    FileAppend, %var% between %VarLow% and %VarHigh%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "3.1415"
                                 varLow := "2"
                                 varHigh := "4"
                                 if (var >= varLow && var <= varHigh)
                                    FileAppend, %var% between %VarLow% and %VarHigh%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   IfBetweenAlphabetically()
   {
      input_script := "
         (Join`r`n %
                                 var = boy
                                 if var between blue and red
                                    FileAppend, %var% is alphabetically between 'blue' and 'red', *
         )"

      expected := "
         (Join`r`n %
                                 var := "boy"
                                 if (var >= "blue" && var <= "red")
                                    FileAppend, %var% is alphabetically between 'blue' and 'red', *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   RenameVars()
   {
      input_script := "
         (Join`r`n %
                                 RunWait, %comspec% /c dir c:\
         )"

      expected := "
         (Join`r`n %
                                 RunWait, %A_ComSpec% /c dir c:\
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   RenameVarsOrder()
   {
      input_script := "
         (Join`r`n %
                                 Loop, Files, Yunit\*.*
                                 {
                                    FileAppend, %A_LoopFileFullPath%``n%A_LoopFileLongPath%, *
                                    break
                                 }
         )"

      expected := "
         (Join`r`n %
                                 Loop, Files, Yunit\*.*
                                 {
                                    FileAppend, %A_LoopFilePath%``n%A_LoopFileFullPath%, *
                                    break
                                 }
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   RenameFunc()
   {
      input_script := "
         (Join`r`n %
                                 FileAppend, % Asc("t"), *
         )"

      expected := "
         (Join`r`n %
                                 FileAppend, % Ord("t"), *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   RenameMultiple()
   {
      input_script := "
         (Join`r`n %
                                 FileAppend, % (true) ? Asc("t") . ComSpec : Asc("w") . ComSpec, *
         )"

      expected := "
         (Join`r`n %
                                 FileAppend, % (true) ? Ord("t") . A_ComSpec : Ord("w") . A_ComSpec, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   EscapedCommas()
   {
      input_script := "
         (Join`r`n %
                                 list := "one,two,three"
                                 StringReplace list, list, `,, `,, UseErrorLevel
                                 FileAppend, %ErrorLevel%, *
         )"

      expected := "
         (Join`r`n %
                                 list := "one,two,three"
                                 StrReplace, list, %list%, `,, `,, ErrorLevel
                                 FileAppend, %ErrorLevel%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   Sort()
   {
      input_script := "
         (Join`r`n %
                                 MyVar = 5,3,7,9,1,13,999,-4
                                 Sort, MyVar, N D,  ; Sort numerically, use comma as delimiter.
                                 FileAppend, %MyVar%, *
         )"

      expected := "
         (Join`r`n %
                                 MyVar := "5,3,7,9,1,13,999,-4"
                                 Sort, MyVar, %MyVar%, N D,  ; Sort numerically, use comma as delimiter.
                                 FileAppend, %MyVar%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   SplitPath()
   {
      input_script := "
         (Join`r`n %
                                 FullFileName = C:\My Documents\Address List.txt
                                 SplitPath, FullFileName, name
                                 SplitPath, FullFileName, , dir
                                 FileAppend, %name%``n%dir%, *
         )"

      expected := "
         (Join`r`n %
                                 FullFileName := "C:\My Documents\Address List.txt"
                                 SplitPath, %FullFileName%, name
                                 SplitPath, %FullFileName%, , dir
                                 FileAppend, %name%``n%dir%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   SplitPath_expr_var()
   {
      input_script := "
         (Join`r`n %
                                 FullFileName = C:\My Documents\Address List.txt
                                 SplitPath, % FullFileName, name
                                 SplitPath, % FullFileName, , dir
                                 FileAppend, %name%``n%dir%, *
         )"

      expected := "
         (Join`r`n %
                                 FullFileName := "C:\My Documents\Address List.txt"
                                 SplitPath, % FullFileName, name
                                 SplitPath, % FullFileName, , dir
                                 FileAppend, %name%``n%dir%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   SplitPath_expr_str()
   {
      input_script := "
         (Join`r`n %
                                 SplitPath, % "C:\My Documents\Address List.txt", name
                                 SplitPath, % "C:\My Documents\Address List.txt", , dir
                                 FileAppend, %name%``n%dir%, *
         )"

      expected := "
         (Join`r`n %
                                 SplitPath, % "C:\My Documents\Address List.txt", name
                                 SplitPath, % "C:\My Documents\Address List.txt", , dir
                                 FileAppend, %name%``n%dir%, *
         )"

      ; first test that our expected code actually produces the same results in v2
      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected, "input v1 execution != expected v2 execution")

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ;FileAppend, % expected, expected.txt
      ;FileAppend, % converted, converted.txt
      ;Run, ..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "%A_ScriptDir%\expected.txt" "%A_ScriptDir%\converted.txt"
      Yunit.assert(converted = expected, "converted output script != expected output script")
   }

   End()
   {
   }
}


class ToExpTests
{
   Begin()
   {
   }

   SurroundQuotes()
   {
      Yunit.assert(ToExp("") = "`"`"")
      Yunit.assert(ToExp("hello") = "`"hello`"")
      Yunit.assert(ToExp("hello world") = "`"hello world`"")
   }

   QuotesInsideString()
   {
      orig := "the man said, `"hello`""
      expected := "`"the man said, ```"hello```"`""
      converted := ToExp(orig)
      ;Msgbox, expected: %expected%`nconverted: %converted%
      Yunit.assert(converted = expected)
   }

   RemovePercents()
   {
      Yunit.assert(ToExp("`%hello`%") = "hello")
      Yunit.assert(ToExp("`%hello`%world") = "hello . `"world`"")
      Yunit.assert(ToExp("`%hello`% world") = "hello . `" world`"")
      Yunit.assert(ToExp("one `%two`% three") = "`"one `" . two . `" three`"")
   }
   
   RemoveEscapedCommas()
   {
      Yunit.assert(ToExp("hello``,world") = "`"hello,world`"")
   }

   PercentDerefsInsideStrings()
   {
      /*
         from:
         https://lexikos.github.io/v2/docs/Variables.htm#Operators

         Within a quoted string: Evaluates Expr and inserts the result at that position within the string. 
         For example, the following are equivalent:

         MsgBox("Hello, %A_UserName%!")
         MsgBox, Hello`, %A_Username%!
         MsgBox("Hello, " A_UserName "!")
      */

      ; decide whether to remove the percents and concatenate like above in RemovePercents()
      ; or to just wrap quotes around everything and leave the percents

      ; Yunit.assert(ToExp("`%hello`%world") = "`"`%hello`%world`"")
   }

   Numbers()
   {
      Yunit.assert(ToExp("10") = "10")
   }

   End()
   {
   }
}


class ToStringExprTests
{
   SurroundQuotes()
   {
      Yunit.assert(ToStringExpr("") = "`"`"")
      Yunit.assert(ToStringExpr("hello") = "`"hello`"")
      Yunit.assert(ToStringExpr("hello world") = "`"hello world`"")
   }

   QuotesInsideString()
   {
      orig := "the man said, `"hello`""
      expected := "`"the man said, ```"hello```"`""
      converted := ToStringExpr(orig)
      ;Msgbox, expected: %expected%`nconverted: %converted%
      Yunit.assert(converted = expected)
   }

   RemovePercents()
   {
      Yunit.assert(ToStringExpr("`%hello`%") = "hello")
      Yunit.assert(ToStringExpr("`%hello`%world") = "hello . `"world`"")
      Yunit.assert(ToStringExpr("`%hello`% world") = "hello . `" world`"")
      Yunit.assert(ToStringExpr("one `%two`% three") = "`"one `" . two . `" three`"")
   }

   RemoveEscapedCommas()
   {
      Yunit.assert(ToStringExpr("hello``,world") = "`"hello,world`"")
   }

   Numbers()
   {
      Yunit.assert(ToStringExpr("10") = "`"10`"")
   }
}



class RemoveSurroundingQuotes
{
   RemoveSurroundingQuotes()
   {
      Yunit.assert(RemoveSurroundingQuotes("`"helloworld`""), "helloworld")
   }

   DontRemoveOtherQuotes()
   {
      Yunit.assert(RemoveSurroundingQuotes("`"helloworld,`" he said."), "`"helloworld,`" he said.")
      Yunit.assert(RemoveSurroundingQuotes("`"helloworld"), "`"helloworld")
      Yunit.assert(RemoveSurroundingQuotes("helloworld"), "helloworld")
   }
}


class RemoveSurroundingPercents
{
   RemoveSurroundingPercents()
   {
      Yunit.assert(RemoveSurroundingPercents("`%helloworld`%"), "helloworld")
   }

   DontRemoveOtherPercents()
   {
      Yunit.assert(RemoveSurroundingPercents("`%helloworld,`% he said."), "`%helloworld,`% he said.")
      Yunit.assert(RemoveSurroundingPercents("`%helloworld"), "`%helloworld")
      Yunit.assert(RemoveSurroundingPercents("helloworld"), "helloworld")
   }
}



class ExecScriptTests
{
   ; we pipe the output of FileAppend to StdOutput
   ; then ExecScript() executes the script and reads from StdOut

   Equals()
   {
      input_script := "
         (Join`r`n %
                                 var = hello world
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hello world"
                                 FileAppend, %var%, *
         )"

      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input = result_expected)
   }

   NotEquals()
   {
      input_script := "
         (Join`r`n %
                                 var = hello world
                                 FileAppend, %var%, *
         )"

      expected := "
         (Join`r`n %
                                 var := "hello world "
                                 FileAppend, %var%, *
         )"

      ;result_input    := ExecScript_v1(input_script)
      ;result_expected := ExecScript_v2(expected)
      ;MsgBox, 'input_script' results (v1):`n[%result_input%]`n`n'expected' results (v2):`n[%result_expected%]
      ;Yunit.assert(result_input != result_expected)
   }
}

