#Requires AutoHotKey v2.0
#Include Yunit\Yunit.ahk
#Include Yunit\Window.ahk
#Include ..\ConvertFuncs.ahk
#Include ExecScript.ahk

Yunit.Use(YunitWindow).Test(ConvertTests, ToExpTests, ToStringExprTests
                          , RemoveSurroundingQuotesTests, RemoveSurroundingPercentsTests, ExecScriptTests, BoxTests, FlowTests, GuiTests, MenuTests, WinTests)


class ConvertTests
{
   Begin()
   {
      ; Set this to 'true' to also test that the execution results match for v1 and v2
      ; This works by including a FileAppend line to stdout "*" with some value which
      ; should match for both versions.
      ; this omits some tests such as EnvUpdate and FileSelectFile
      ; This is useful to use if the v2alpha syntax has changed and you need to check
      ; if the conversion is still accurate.
      this.test_exec := false
   }

   End()
   {
   }

   AssignmentString()
   {
      ; we pipe the output of FileAppend to StdOutput
      ; then ExecScript() executes the script and reads from StdOut

      input_script := "
         (Join`r`n
                                 var = hello
                                 msg = %var% world
                                 FileAppend, %msg%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hello"
                                 msg := var . " world"
                                 FileAppend(msg, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   AssignmentStringWithQuotes()
   {
      input_script := "
         (Join`r`n
                                 msg = the man said, "hello"
                                 FileAppend, %msg%, *
         )"
      expected := "
         (Join`r`n
                                 msg := "the man said, ``"hello``""
                                 FileAppend(msg, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   AssignmentStringWithQuotesAndVar()
   {
      input_script := "
         (Join`r`n
                                 msg = the man said, "hello" %A_Index%
                                 FileAppend, %msg%, *
         )"
      expected := "
         (Join`r`n
                                 msg := "the man said, ``"hello``" " . A_Index
                                 FileAppend(msg, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   AssignmentStringWithPreceedingSpaces()
   {
      input_script := "
         (Join`r`n
                                 msg =    hello world
                                 FileAppend, %msg%, *
         )"
      expected := "
         (Join`r`n
                                 msg := "hello world"
                                 FileAppend(msg, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   AssignmentNumber()
   {
      input_script := "
         (Join`r`n
                                 var = 2
                                 if (var = 2)
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "2"
                                 if (var = 2)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   CommentBlock()
   {
      input_script := "
         (Join`r`n
                                 var = hi
                                 /`*
                                 var = hello
                                 *`/
                                 var2 = hello2
                                 FileAppend, var=%var%``nvar2=%var2%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hi"
                                 /`*
                                 var = hello
                                 *`/
                                 var2 := "hello2"
                                 FileAppend("var=" var "``nvar2=" var2, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   CommentBlock_ContinuationInside()
   {
      input_script := "
         (Join`r`n
                                 var = hi
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
         (Join`r`n
                                 var := "hi"
                                 /`*
                                 var =
                                 `(
                                 blah blah
                                 `)
                                 *`/
                                 var2 := "hello2"
                                 FileAppend("var=" var "``nvar2=" var2, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Continuation_Assignment()
   {
      input_script := "
         (Join`r`n
                                 Sleep, 100
                                 var =
                                 `(
                                 line1
                                 line2
                                 `)
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 Sleep(100)
                                 var := "
                                 `(
                                 line1
                                 line2
                                 `)"
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Continuation_Assignment_indented()
   {
      input_script := "
         (Join`r`n
                                 var =
                                    `(
                                    hello world
                                    `)
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "
                                    `(
                                    hello world
                                    `)"
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Continuation_NewlinePreceding()
   {
      input_script := "
         (Join`r`n
                                 var =
                                 `(
                                 hello
                                 `)
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "
                                 `(
                                 hello
                                 `)"
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }
   /*
   Continuation_CommandParam()
   {
      input_script := "
         (Join`r`n
                                 var := 9
                                 FileAppend,
                                 `(
                                 %var%
                                 line2
                                 `), *
         )"
      expected := "
         (Join`r`n
                                 var := 9
                                 FileAppend,
                                 `(
                                 %var%
                                 line2
                                 `), *
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }
   */

   Ternary_NotAContinuation()
   {
      input_script := "
         (Join`r`n
                                 x := 50
                                 y := 60
                                 var := true
                                 ( var ) ? x : y
                                 var2 = value2
         )"
      expected := "
         (Join`r`n
                                 x := 50
                                 y := 60
                                 var := true
                                 ( var ) ? x : y
                                 var2 := "value2"
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_EqualsString()
   {
      input_script := "
         (Join`r`n
                                 var := "helloworld"
                                 if var = helloworld
                                    FileAppend, equal, *
         )"
      expected := "
         (Join`r`n
                                 var := "helloworld"
                                 if (var = "helloworld")
                                    FileAppend("equal", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_NotEqualsEmptyString()
   {
      input_script := "
         (Join`r`n
                                 var = 3
                                 if var !=
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "3"
                                 if (var != "")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_EqualsInt()
   {
      input_script := "
         (Join`r`n
                                 var = 8
                                 if var = 8
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "8"
                                 if (var = 8)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_GreaterThanInt()
   {
      input_script := "
         (Join`r`n
                                 var = 10
                                 if var > 8
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "10"
                                 if (var > 8)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_EqualsVariable()
   {
      input_script := "
         (Join`r`n
                                 MyVar = joe
                                 MyVar2 = joe
                                 if MyVar = %MyVar2%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
         )"
      expected := "
         (Join`r`n
                                 MyVar := "joe"
                                 MyVar2 := "joe"
                                 if (MyVar = MyVar2)
                                     FileAppend("The contents of MyVar and MyVar2 are identical.", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_EqualsStringAndVariable()
   {
      input_script := "
         (Join`r`n
                                 MyVar = joe
                                 MyVar2 = "hello" joe
                                 if MyVar2 = "hello" %MyVar%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
         )"
      expected := "
         (Join`r`n
                                 MyVar := "joe"
                                 MyVar2 := "``"hello``" joe"
                                 if (MyVar2 = "``"hello``" " MyVar)
                                     FileAppend("The contents of MyVar and MyVar2 are identical.", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_Else()
   {
      input_script := "
         (Join`r`n
                                 MyVar = joe
                                 MyVar2 =
                                 if MyVar = %MyVar2%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
                                 else if MyVar =
                                     FileAppend, MyVar is empty/blank, *
         )"
      expected := "
         (Join`r`n
                                 MyVar := "joe"
                                 MyVar2 := ""
                                 if (MyVar = MyVar2)
                                     FileAppend("The contents of MyVar and MyVar2 are identical.", "*")
                                 else if (MyVar = "")
                                     FileAppend("MyVar is empty/blank", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Traditional_If_Else_NotEquals()
   {
      input_script := "
         (Join`r`n
                                 MyVar = joe
                                 MyVar2 = joe2
                                 if MyVar = %MyVar2%
                                     FileAppend, The contents of MyVar and MyVar2 are identical., *
                                 else if MyVar <>
                                     FileAppend, MyVar is not empty/blank, *
         )"
      expected := "
         (Join`r`n
                                 MyVar := "joe"
                                 MyVar2 := "joe2"
                                 if (MyVar = MyVar2)
                                     FileAppend("The contents of MyVar and MyVar2 are identical.", "*")
                                 else if (MyVar != "")
                                     FileAppend("MyVar is not empty/blank", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Expression_If_Function()
   {
      input_script := "
         (Join`r`n
                                 if MyFunc()
                                    FileAppend, %var%, *

                                 MyFunc() {
                                    global var := 777
                                    return true
                                 }
         )"
      expected := "
         (Join`r`n
                                 if MyFunc()
                                    FileAppend(var, "*")

                                 MyFunc() {
                                    global var := 777
                                    return true
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Expression_If_Not()
   {
      input_script := "
         (Join`r`n
                                 var := ""
                                 if not var =
                                    FileAppend, var is not empty, *
                                 else
                                    FileAppend, var is empty, *
         )"
      expected := "
         (Join`r`n
                                 var := ""
                                 if not (var = "")
                                    FileAppend("var is not empty", "*")
                                 else
                                    FileAppend("var is empty", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Expression_If_NoSpaceBeforeParen()
   {
      input_script := "
         (Join`r`n
                                 method := 1
                                 if( method = 1 )
                                    FileAppend, %method%, *
         )"
      expected := "
         (Join`r`n
                                 method := 1
                                 if( method = 1 )
                                    FileAppend(method, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   While_NoSpaceBeforeParen()
   {
      input_script := "
         (Join`r`n
                                 method := 0
                                 while( method = 1 )
                                    break
                                 FileAppend, %method%, *
         )"
      expected := "
         (Join`r`n
                                 method := 0
                                 while( method = 1 )
                                    break
                                 FileAppend(method, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_CommandThenComma()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfEqual, var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_CommandThenSpace()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfEqual var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_SameLineAction()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfEqual var, value, FileGetSize, size, %A_ScriptDir%\Tests.ahk
                                 FileAppend, %size%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")
                                     size := FileGetSize(A_ScriptDir "\Tests.ahk")
                                 FileAppend(size, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_CommandThenMultipleSpaces()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfEqual    var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_LeadingSpacesInParam()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfEqual, var,     value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_EscapedComma()
   {
      input_script := "
         (Join`r`n
                                 var = ,
                                 IfEqual, var, ``,
                                    FileAppend, var is a comma, *
         )"
      expected := "
         (Join`r`n
                                 var := ","
                                 if (var = ",")
                                    FileAppend("var is a comma", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_EscapedCommaMidString()
   {
      input_script := "
         (Join`r`n
                                 var = hello,world
                                 IfEqual, var, hello``,world
                                    FileAppend, var matches, *
         )"
      expected := "
         (Join`r`n
                                 var := "hello,world"
                                 if (var = "hello,world")
                                    FileAppend("var matches", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_EscapedCommaNotNeededInLastParam()
   {
      ; "Commas that appear within the last parameter of a command do not need to be escaped because
      ;  the program knows to treat them literally."
      ;
      ; from:   https://autohotkey.com/docs/commands/_EscapeChar.htm
      input_script := "
         (Join`r`n
                                 var = ,
                                 IfEqual, var, ,
                                    FileAppend, var is a comma, *
         )"
      expected := "
         (Join`r`n
                                 var := ","
                                 if (var = ",")
                                    FileAppend("var is a comma", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfEqual_EscapedCommaNotNeededMidString()
   {
      ; "Commas that appear within the last parameter of a command do not need to be escaped because
      ;  the program knows to treat them literally."
      ;
      ; from:   https://autohotkey.com/docs/commands/_EscapeChar.htm
      input_script := "
         (Join`r`n
                                 var = hello,world
                                 IfEqual, var, hello,world
                                    FileAppend, var matches, *
         )"
      expected := "
         (Join`r`n
                                 var := "hello,world"
                                 if (var = "hello,world")
                                    FileAppend("var matches", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfNotEqual()
   {
      input_script := "
         (Join`r`n
                                 var = val
                                 IfNotEqual, var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "val"
                                 if (var != "value")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfGreaterOrEqual()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfGreaterOrEqual, var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (StrCompare(var, "value") >= 0)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfGreater()
   {
      input_script := "
         (Join`r`n
                                 var = zzz
                                 IfGreater, var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "zzz"
                                 if (StrCompare(var, "value") > 0)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfGreater_Numbers()
   {
      input_script := "
         (Join`r`n
                                 var := 4
                                 IfGreater, var, 3
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := 4
                                 if (var > 3)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfLess()
   {
      input_script := "
         (Join`r`n
                                 var = hhh
                                 IfLess, var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hhh"
                                 if (StrCompare(var, "value") < 0)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfLess_Numbers()
   {
      input_script := "
         (Join`r`n
                                 var := 1
                                 IfLess, var, 4
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := 1
                                 if (var < 4)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfLessOrEqual()
   {
      input_script := "
         (Join`r`n
                                 var = hhh
                                 IfLessOrEqual, var, value
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hhh"
                                 if (StrCompare(var, "value") <= 0)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvMult()
   {
      input_script := "
         (Join`r`n
                                 var = 3
                                 EnvMult, var, 5
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "3"
                                 var *= 5
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvMult_ExpressionParam()
   {
      input_script := "
         (Join`r`n
                                 var = 1
                                 var2 = 2
                                 EnvMult, var, var2
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "1"
                                 var2 := "2"
                                 var *= var2
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvAdd()
   {
      input_script := "
         (Join`r`n
                                 var = 1
                                 EnvAdd, var, 2
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "1"
                                 var += 2
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvAdd_time()
   {
      input_script := "
         (Join`r`n
                                 var = %A_Now%
                                 EnvAdd, var, 7, days
                                 FormatTime, var, %var%, ShortDate
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := A_Now
                                 var := DateAdd(var, 7, "days")
                                 var := FormatTime(var, "ShortDate")
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvAdd_var()
   {
      input_script := "
         (Join`r`n
                                 var = 4
                                 two := 2
                                 EnvAdd, var, two
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "4"
                                 two := 2
                                 var += two
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvAdd_var_forcedexpr()
   {
      input_script := "
         (Join`r`n
                                 var = 4
                                 two := 2
                                 EnvAdd, var, % two
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "4"
                                 two := 2
                                 var += two
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvSub()
   {
      input_script := "
         (Join`r`n
                                 var = 5
                                 EnvSub, var, 2
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "5"
                                 var -= 2
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvSub_time()
   {
      input_script := "
         (Join`r`n
                                 var1 = 20050126
                                 var2 = 20040126
                                 EnvSub, var1, %var2%, days
                                 FileAppend, %var1%, *
         )"
      expected := "
         (Join`r`n
                                 var1 := "20050126"
                                 var2 := "20040126"
                                 var1 := DateDiff(var1, var2, "days")
                                 FileAppend(var1, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvSub_ExpressionValue()
   {
      input_script := "
         (Join`r`n
                                 var = 9
                                 value = 6
                                 EnvSub, var, value
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "9"
                                 value := "6"
                                 var -= value
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues()
   {
      input_script := "
         (Join`r`n
                                 five := MyFunc()
                                 FileAppend, %five%, *
                                 MyFunc(var=5) {
                                    return var
                                 }
         )"
      expected := "
         (Join`r`n
                                 five := MyFunc()
                                 FileAppend(five, "*")
                                 MyFunc(var:=5) {
                                    return var
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_OTB()
   {
      input_script := "
         (Join`r`n
                                 five := MyFunc()
                                 FileAppend, %five%, *
                                 MyFunc(var=5) {
                                    return var
                                 }
         )"
      expected := "
         (Join`r`n
                                 five := MyFunc()
                                 FileAppend(five, "*")
                                 MyFunc(var:=5) {
                                    return var
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_CommasInParamString()
   {
      input_script := "
         (Join`r`n
                                 Concat(5)

                                 Concat(one, two="hello,world")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 Concat(5)

                                 Concat(one, two:="hello,world")
                                 {
                                    FileAppend(one . two, "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_CommasInCallString()
   {
      input_script := "
         (Join`r`n
                                 Concat("joe,says,")

                                 Concat(one, two="hello,world")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 Concat("joe,says,")

                                 Concat(one, two:="hello,world")
                                 {
                                    FileAppend(one . two, "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_EqualSignInDefinitionString()
   {
      input_script := "
         (Join`r`n
                                 Concat(5)

                                 Concat(one, two="+5=10")
                                 {
                                    FileAppend, % one . two, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 Concat(5)

                                 Concat(one, two:="+5=10")
                                 {
                                    FileAppend(one . two, "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_EqualSignInCallerString()
   {
      input_script := "
         (Join`r`n
                                 msg("me=god")

                                 msg(var)
                                 {
                                    FileAppend, % var, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 msg("me=god")

                                 msg(var)
                                 {
                                    FileAppend(var, "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_TernaryInCall()
   {
      ; dont replace the equal sign in the ternary during the function CALL
      input_script := "
         (Join`r`n
                                 var := 1
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two="2")
                                 {
                                    FileAppend, % one + two, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 var := 1
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two:="2")
                                 {
                                    FileAppend(one + two, "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FunctionDefaultParamValues_WholeShebang()
   {
      input_script := "
         (Join`r`n
                                 var = 5
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two="hello,world", three = 3, four = "does 2+2=4?")
                                 {
                                    FileAppend, % one . two . three . four, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 var := "5"
                                 Concat((var=5) ? 5 : 0)

                                 Concat(one, two:="hello,world", three := 3, four := "does 2+2=4?")
                                 {
                                    FileAppend(one . two . three . four, "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   NoEnv_Remove()
   {
      input_script := "
         (Join`r`n
                                 #NoEnv
                                 FileAppend, hi, *
         )"
      expected := "
         (Join`r`n
                                 ; V1toV2: Removed #NoEnv
                                 FileAppend("hi", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   SetFormat_Remove()
   {
      input_script := "
         (Join`r`n
                                 SetFormat, integerfast, H
                                 FileAppend, hi, *
         )"
      expected := "
         (Join`r`n
                                 ; V1toV2: Removed SetFormat, integerfast, H
                                 FileAppend("hi", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   DriveGetSpaceFree()
   {
      input_script := "
         (Join`r`n
                                 DriveSpaceFree, FreeSpace, c:\
                                 FileAppend, %FreeSpace%, *
         )"
      expected := "
         (Join`r`n
                                 FreeSpace := DriveGetSpaceFree("c:\")
                                 FileAppend(FreeSpace, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileGetSize()
   {
      input_script := "
         (Join`r`n
                                 FileGetSize, size, %A_ScriptDir%\Tests.ahk
                                 FileAppend, %size%, *
         )"
      expected := "
         (Join`r`n
                                 size := FileGetSize(A_ScriptDir "\Tests.ahk")
                                 FileAppend(size, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringUpper()
   {
      input_script := "
         (Join`r`n
                                 var = Chris Mallet
                                 StringUpper, newvar, var
                                 FileAppend, %newvar%, *
         )"
      expected := "
         (Join`r`n
                                 var := "Chris Mallet"
                                 newvar := StrUpper(var)
                                 FileAppend(newvar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringLower()
   {
      input_script := "
         (Join`r`n
                                 var = chris mallet
                                 StringLower, newvar, var, T
                                 if (newvar == "Chris Mallet")
                                    FileAppend, it worked, *
         )"
      expected := "
         (Join`r`n
                                 var := "chris mallet"
                                 newvar := StrTitle(var)
                                 if (newvar == "Chris Mallet")
                                    FileAppend("it worked", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringLen()
   {
      input_script := "
         (Join`r`n
                                 InputVar := "The Quick Brown Fox Jumps Over the Lazy Dog"
                                 StringLen, length, InputVar
                                 FileAppend, The length of InputVar is %length%., *
         )"
      expected := "
         (Join`r`n
                                 InputVar := "The Quick Brown Fox Jumps Over the Lazy Dog"
                                 length := StrLen(InputVar)
                                 FileAppend("The length of InputVar is " length ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 Needle = def
                                 StringGetPos, pos, Haystack, %Needle%
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 Needle := "def"
                                 pos := InStr(Haystack, Needle) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_NotFound()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 Needle = xyz
                                 StringGetPos, pos, Haystack, %Needle%
                                 FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 Needle := "xyz"
                                 pos := InStr(Haystack, Needle) - 1
                                 FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_LiteralText()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 StringGetPos, pos, Haystack, def
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 pos := InStr(Haystack, "def") - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_SearchLeftOccurance()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = def
                                 StringGetPos, pos, Haystack, %Needle%, L2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "def"
                                 pos := InStr(Haystack, Needle,, (0)+1, 2) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   /*
   StringGetPos_SearchLeftOccurance_StringCaseSense()
   {
      input_script := "
         (Join`r`n
                                 StringCaseSense, on
                                 Haystack = abcdefabcdef
                                 Needle = DEF
                                 StringGetPos, pos, Haystack, %Needle%, L2
                                 FileAppend, The string was found at position %pos%, *
         )"
      expected := "
         (Join`r`n
                                 StringCaseSense("on")
                                 Haystack := "abcdefabcdef"
                                 Needle := "DEF"
                                 pos := InStr(Haystack, Needle, (A_StringCaseSense="On") ? true : false, (0)+1, 2) - 1
                                 FileAppend("The string was found at position " pos, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }
   */

   StringGetPos_SearchRight()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = bcd
                                 StringGetPos, pos, Haystack, %Needle%, R
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "bcd"
                                 pos := InStr(Haystack, Needle,, -1*((0)+1)) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_SearchRightOccurance()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, R2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle,, -1*((0)+1), -2) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_SearchRight_Literal1Occurrence()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = bcd
                                 StringGetPos, pos, Haystack, %Needle%, 1
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "bcd"
                                 pos := InStr(Haystack, Needle,, -1*((0)+1)) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetLeft()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%,, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle,, (4)+1) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetLeftVariable()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 var = 2
                                 StringGetPos, pos, Haystack, %Needle%,, %var%
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 var := "2"
                                 pos := InStr(Haystack, Needle,, (var)+1) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetLeftExpressionVariable()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 var = 1
                                 StringGetPos, pos, Haystack, %Needle%,, var+2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 var := "1"
                                 pos := InStr(Haystack, Needle,, (var+2)+1) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetRightExpressionVariableOccurences()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdefabcdef
                                 Needle = cde
                                 var = 0
                                 StringGetPos, pos, Haystack, %Needle%, R2, var+2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdefabcdef"
                                 Needle := "cde"
                                 var := "0"
                                 pos := InStr(Haystack, Needle,, -1*((var+2)+1), -2) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetLeftOccurence()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, L2, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle,, (4)+1, 2) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetRight()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, R, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle,, -1*((4)+1)) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_OffsetRightOccurence()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdefabcdef
                                 Needle = cde
                                 StringGetPos, pos, Haystack, %Needle%, r2, 4
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdefabcdef"
                                 Needle := "cde"
                                 pos := InStr(Haystack, Needle,, -1*((4)+1), -2) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringGetPos_Duplicates()
   {
      input_script := "
         (Join`r`n
                                 Haystack = FFFF
                                 Needle = FF
                                 StringGetPos, pos, Haystack, %Needle%, L2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "FFFF"
                                 Needle := "FF"
                                 pos := InStr(Haystack, Needle,, (0)+1, 2) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringMid()
   {
      input_script := "
         (Join`r`n
                                 Source = Hello this is a test.
                                 StringMid, out, Source, 7
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 Source := "Hello this is a test."
                                 out := SubStr(Source, 7)
                                 FileAppend(out, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringMid_Count()
   {
      input_script := "
         (Join`r`n
                                 Source = Hello this is a test.
                                 StringMid, out, Source, 7, 4
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 Source := "Hello this is a test."
                                 out := SubStr(Source, 7, 4)
                                 FileAppend(out, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringMid_CountStartVar()
   {
      input_script := "
         (Join`r`n
                                 start = 7
                                 Source = Hello this is a test.
                                 StringMid, out, Source, %start%, 4
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 start := "7"
                                 Source := "Hello this is a test."
                                 out := SubStr(Source, start, 4)
                                 FileAppend(out, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringMid_StartAndCountExpressions()
   {
      input_script := "
         (Join`r`n
                                 start = 2
                                 count = 4
                                 Source = Hello this is a test.
                                 StringMid, out, Source, start+5, count
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 start := "2"
                                 count := "4"
                                 Source := "Hello this is a test."
                                 out := SubStr(Source, start+5, count)
                                 FileAppend(out, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringMid_Count_L()
   {
      input_script := "
         (Join`r`n
                                 InputVar = The Red Fox
                                 StringMid, out, InputVar, 7, 3, L
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 InputVar := "The Red Fox"
                                 out := SubStr(SubStr(InputVar, 1, 7), StrLen(InputVar) >= 7 ? -3 : StrLen(InputVar)-7)
                                 FileAppend(out, "*")
         )"
                                 ; or two lines:
                                 ;out := SubStr(InputVar, 1, 7)
                                 ;out := SubStr(out, -3)

      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringMid_Count_L_expression()
   {
      input_script := "
         (Join`r`n
                                 InputVar = The Red Fox
                                 left = LOL
                                 StringMid, out, InputVar, 7, 3, %left%
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 InputVar := "The Red Fox"
                                 left := "LOL"
                                 if (SubStr(left, 1, 1) = "L")
                                     out := SubStr(SubStr(InputVar, 1, 7), -3)
                                 else
                                     out := SubStr(InputVar, 7, 3)
                                 FileAppend(out, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringLeft()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 StringLeft, OutputVar, Str, 4
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 OutputVar := SubStr(Str, 1, 4)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringLeft_CountExpr()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 3
                                 StringLeft, OutputVar, Str, count+1
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 3
                                 OutputVar := SubStr(Str, 1, count+1)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringRight()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 StringRight, OutputVar, Str, 5
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 OutputVar := SubStr(Str, -1*(5))
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringRight_CountExpr()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 6
                                 StringRight, OutputVar, Str, count-1
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 6
                                 OutputVar := SubStr(Str, -1*(count-1))
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringTrimLeft()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 StringTrimLeft, OutputVar, Str, 5
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 OutputVar := SubStr(Str, (5)+1)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringTrimLeft_CountExpr()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 5
                                 StringTrimLeft, OutputVar, Str, count*1
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 5
                                 OutputVar := SubStr(Str, (count*1)+1)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringTrimRight()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 StringTrimRight, OutputVar, Str, 6
                                 FileAppend, [%OutputVar%], *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 OutputVar := SubStr(Str, 1, -1*(6))
                                 FileAppend("[" OutputVar "]", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringTrimRight_CountExpr()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 3
                                 StringTrimRight, OutputVar, Str, count+3
                                 FileAppend, [%OutputVar%], *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 3
                                 OutputVar := SubStr(Str, 1, -1*(count+3))
                                 FileAppend("[" OutputVar "]", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   RemoveTrailingFuncParams()
   {
      input_script := "
         (Join`r`n
                                 ToolTip, helloworld
                                 FileAppend, hi, *
         )"
      expected := "
         (Join`r`n
                                 ToolTip("helloworld")
                                 FileAppend("hi", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Preserve_Indentation()
   {
      ; dont use LTrim and instead rely on AHK v2 default smart LTrim
      input_script := "
         (Join`r`n
                                 if (1) {
                                    var = val
                                    if var = hello
                                 		ToolTip, this line starts with 2 tab characters
                                    else {
                                       ifequal, var, val
                                          StringGetPos, pos, var, al
                                    }
                                 }
                                 FileAppend, pos=%pos%, *
         )"
      expected := "
         (Join`r`n
                                 if (1) {
                                    var := "val"
                                    if (var = "hello")
                                 		ToolTip("this line starts with 2 tab characters")
                                    else {
                                       if (var = "val")
                                          pos := InStr(var, "al") - 1
                                    }
                                 }
                                 FileAppend("pos=" pos, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   WinGetActiveTitle()
   {
      input_script := "
         (Join`r`n
                                 WinGetActiveTitle, OutputVar
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 OutputVar := WinGetTitle("A")
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   WinGetActiveStats()
   {
      input_script := "
         (Join`r`n
                                 WinGetActiveStats, title, w, h, x, y
                                 FileAppend, %title%-%w%-%h%-%x%-%y%, *
         )"
      expected := "
         (Join`r`n
                                 title := WinGetTitle("A")
                                 WinGetPos(&x, &y, &w, &h, "A")
                                 FileAppend(title "-" w "-" h "-" x "-" y, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_Assignment()
   {
      input_script := "
         (Join`r`n
                                 var = value     ; comment after 5 spaces
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"     ; comment after 5 spaces
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_TraditionalIf()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 if var = value     ; comment after 5 spaces
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")     ; comment after 5 spaces
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_EnvAdd()
   {
      input_script := "
         (Join`r`n
                                 var = 1
                                 EnvAdd, var, 2     ; comment after 5 spaces
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "1"
                                 var += 2     ; comment after 5 spaces
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_IfEqual()
   {
      input_script := "
         (Join`r`n
                                 var = 1
                                 IfEqual, var, 1     ; comment after 5 spaces
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "1"
                                 if (var = 1)     ; comment after 5 spaces
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_SkippedLines()
   {
      input_script := "
         (Join`r`n
                                 var = 1
                                    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
         )"
      expected := "
         (Join`r`n
                                 var := "1"
                                 ; V1toV2: Removed    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_StringTrimLeft()
   {
      input_script := "
         (Join`r`n
                                 x = +plus
                                 StringTrimLeft x, x, 1           ; leading +x -> x
                                 IfEqual, x, plus
                                    FileAppend, %x%, *
         )"
      expected := "
         (Join`r`n
                                 x := "+plus"
                                 x := SubStr(x, (1)+1)           ; leading +x -> x
                                 if (x = "plus")
                                    FileAppend(x, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   PreserveComment_UntouchedLines()
   {
      input_script := "
         (Join`r`n
                                 var := "value"     ; this line won't be changed by the converter
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"     ; this line won't be changed by the converter
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   /*
   AutoTrim()
   {
      input_script := "
         (Join`r`n
                                 var := " helloworld "
                                 var2 = %var%
                                 FileAppend, %var2%, *
         )"
      expected := "
         (Join`r`n
                                 var := " helloworld "
                                 var2 := Trim(var)
                                 FileAppend(var2, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }
   */

   ReturnDeref()
   {
      input_script := "
         (Join`r`n
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return %var%
                                 }
         )"
      expected := "
         (Join`r`n
                                 FileAppend(MyFunc(), "*")

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return var
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ReturnNoDeref()
   {
      input_script := "
         (Join`r`n
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return var . hi . (1+1) ; with comment
                                 }
         )"
      expected := "
         (Join`r`n
                                 FileAppend(MyFunc(), "*")

                                 MyFunc() {
                                    var := "hi"
                                    hi := "hello"
                                    return var . hi . (1+1) ; with comment
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ReturnNoDerefFuncCall()
   {
      input_script := "
         (Join`r`n
                                 FileAppend, % MyFunc(), *

                                 MyFunc() {
                                    var := "hi"
                                    return OtherFunc(var, "world", 3)
                                 }

                                 OtherFunc(one, two, three) {
                                    return one . two
                                 }
         )"
      expected := "
         (Join`r`n
                                 FileAppend(MyFunc(), "*")

                                 MyFunc() {
                                    var := "hi"
                                    return OtherFunc(var, "world", 3)
                                 }

                                 OtherFunc(one, two, three) {
                                    return one . two
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfVarIsType()
   {
      input_script := "
         (Join`r`n
                                 var = 3.1415
                                 if var is float
                                    FileAppend, %var% is float, *
                                 else if var is integer
                                    FileAppend, %var% is int, *
         )"
      expected := "
         (Join`r`n
                                 var := "3.1415"
                                 if isFloat(var)
                                    FileAppend(var " is float", "*")
                                 else if isInteger(var)
                                    FileAppend(var " is int", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfVarIsType_Deref()
   {
      input_script := "
         (Join`r`n
                                 var = 3.1415
                                 mytype = float
                                 if var is %mytype%
                                    FileAppend, %var% is float, *
         )"
      expected := "
         (Join`r`n
                                 var := "3.1415"
                                 mytype := "float"
                                 if is%mytype%(var)
                                    FileAppend(var " is float", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfVarIsTypeNot()
   {
      input_script := "
         (Join`r`n
                                 var = 3.1415
                                 if var is not float
                                    FileAppend, %var% is not float, *
                                 else if var is not integer
                                    FileAppend, %var% is not int, *
         )"
      expected := "
         (Join`r`n
                                 var := "3.1415"
                                 if !isFloat(var)
                                    FileAppend(var " is not float", "*")
                                 else if !isInteger(var)
                                    FileAppend(var " is not int", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringReplace()
   {
      input_script := "
         (Join`r`n
                                 OldStr := "The_quick_brown_fox"
                                 StringReplace, NewStr, OldStr, _
                                 FileAppend, %NewStr%, *
         )"
      expected := "
         (Join`r`n
                                 OldStr := "The_quick_brown_fox"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 NewStr := StrReplace(OldStr, "_",,,, 1)
                                 FileAppend(NewStr, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringReplace_One()
   {
      input_script := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%, +
                                 FileAppend, %NewStr%, *
         )"
      expected := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 NewStr := StrReplace(OldStr, A_Space, "+",,, 1)
                                 FileAppend(NewStr, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringReplace_All()
   {
      input_script := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%, +, All
                                 FileAppend, %NewStr%, *
         )"
      expected := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 NewStr := StrReplace(OldStr, A_Space, "+")
                                 FileAppend(NewStr, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringReplace_All_NoReplaceText()
   {
      input_script := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%,, All
                                 FileAppend, %NewStr%, *
         )"
      expected := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 NewStr := StrReplace(OldStr, A_Space)
                                 FileAppend(NewStr, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   StringReplace_UseErrorLevel()
   {
      input_script := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, %A_Space%, +, UseErrorLevel
                                 FileAppend, number of replacements: %ErrorLevel%, *
         )"
      expected := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 NewStr := StrReplace(OldStr, A_Space, "+",, &ErrorLevel)
                                 FileAppend("number of replacements: " ErrorLevel, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_StringLeft_CountExpr()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 3
                                 StringLeft, OutputVar, Str, % count+1
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 3
                                 OutputVar := SubStr(Str, 1, count+1)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_StringReplace_All()
   {
      input_script := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 StringReplace, NewStr, OldStr, % " ", % "+", All
                                 FileAppend, %NewStr%, *
         )"
      expected := "
         (Join`r`n
                                 OldStr := "The quick brown fox"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 NewStr := StrReplace(OldStr, " ", "+")
                                 FileAppend(NewStr, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_StringMid_StartAndCountExpressions()
   {
      input_script := "
         (Join`r`n
                                 start = 2
                                 count = 4
                                 Source = Hello this is a test.
                                 StringMid, out, Source, % start+5, % count
                                 FileAppend, %out%, *
         )"
      expected := "
         (Join`r`n
                                 start := "2"
                                 count := "4"
                                 Source := "Hello this is a test."
                                 out := SubStr(Source, start+5, count)
                                 FileAppend(out, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_StringGetPos_OffsetLeftExpressionVariable()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefabcdef
                                 Needle = cde
                                 var = 1
                                 StringGetPos, pos, Haystack, %Needle%,, % var+2
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefabcdef"
                                 Needle := "cde"
                                 var := "1"
                                 pos := InStr(Haystack, Needle,, (var+2)+1) - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_StringGetPos_LiteralText()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 StringGetPos, pos, Haystack, % "def"
                                 if pos >= 0
                                     FileAppend, The string was found at position %pos%., *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 pos := InStr(Haystack, "def") - 1
                                 if (pos >= 0)
                                     FileAppend("The string was found at position " pos ".", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_IfEqual_CommandThenComma()
   {
      input_script := "
         (Join`r`n
                                 var = value
                                 IfEqual, var, % "value"
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "value"
                                 if (var = "value")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   ForcedExpression_Traditional_If_GreaterThanInt()
   {
      input_script := "
         (Join`r`n
                                 var = 10
                                 if var > % 4*2
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "10"
                                 if (var > 4*2)
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   CBE2E_var()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 7
                                 StringLeft, OutputVar, Str, count
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 7
                                 OutputVar := SubStr(Str, 1, count)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   CBE2E_var_deref()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 7
                                 StringLeft, OutputVar, Str, %count%
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 7
                                 OutputVar := SubStr(Str, 1, count)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   CBE2E_var_forcedexpr()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 7
                                 StringLeft, OutputVar, Str, % count
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 7
                                 OutputVar := SubStr(Str, 1, count)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   CBE2E_var_forcedexpr_doublederef()
   {
      input_script := "
         (Join`r`n
                                 Str = This is a test.
                                 count := 7
                                 two_letters := "nt"
                                 StringLeft, OutputVar, Str, % cou%two_letters%
                                 FileAppend, %OutputVar%, *
         )"
      expected := "
         (Join`r`n
                                 Str := "This is a test."
                                 count := 7
                                 two_letters := "nt"
                                 OutputVar := SubStr(Str, 1, cou%two_letters%)
                                 FileAppend(OutputVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Sleep()
   {
      input_script := "
         (Join`r`n
                                 Sleep, 500
         )"
      expected := "
         (Join`r`n
                                 Sleep(500)
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Sleep_CBE2T_varexpr()
   {
      input_script := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, half_second
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"
      expected := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep(half_second)
                                 stop := A_TickCount
                                 FileAppend(stop - start, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Sleep_CBE2T_var()
   {
      input_script := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, %half_second%
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"
      expected := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep(half_second)
                                 stop := A_TickCount
                                 FileAppend(stop - start, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Sleep_CBE2T_expr()
   {
      input_script := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, half_second*2
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"
      expected := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep(half_second*2)
                                 stop := A_TickCount
                                 FileAppend(stop - start, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Sleep_CBE2T_exprforced()
   {
      input_script := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep, % half_second*2
                                 stop := A_TickCount
                                 FileAppend, % stop - start, *
         )"
      expected := "
         (Join`r`n
                                 half_second := 500
                                 start := A_TickCount
                                 Sleep(half_second*2)
                                 stop := A_TickCount
                                 FileAppend(stop - start, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EnvUpdate()
   {
      input_script := "
         (Join`r`n
                           EnvUpdate
         )"
      expected := "
         (Join`r`n
                           SendMessage, % WM_SETTINGCHANGE := 0x001A, 0, Environment,, % "ahk_id " . HWND_BROADCAST := "0xFFFF"
         )"
      ; first test that our expected code actually produces the same results in v2
      ; if (this.test_exec = true) {
         ; result_input    := ExecScript_v1(input_script)
         ; result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         ; Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      ; }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   SetEnv()
   {
      input_script := "
         (Join`r`n
                                 SetEnv, var, hello
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hello"
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   SetEnv_UnescapedCommasInLastParam()
   {
      input_script := "
         (Join`r`n
                                 SetEnv, var, h,e, l,l,o
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "h,e, l,l,o"
                                 FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   TooFewParams()
   {
      input_script := "
         (Join`r`n
                                 var := "helloooo"
                                 IfNotEqual, var
                                    FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "helloooo"
                                 if (var != "")
                                    FileAppend(var, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfInString_var()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 Needle = abc
                                 IfInString, Haystack, %Needle%
                                    FileAppend, found, *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 Needle := "abc"
                                 if InStr(Haystack, Needle)
                                    FileAppend("found", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfInString_text()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 IfInString, Haystack, jklm
                                    FileAppend, found, *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 if InStr(Haystack, "jklm")
                                    FileAppend("found", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfInString_SameLineAction()
   {
      input_script := "
         (Join`r`n
                                 Haystack = z.y.x.w
                                 IfInString, Haystack, y.x, SysGet, mouse_btns, 43
                                 FileAppend, %mouse_btns%, *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "z.y.x.w"
                                 if InStr(Haystack, "y.x")
                                     mouse_btns := SysGet(43)
                                 FileAppend(mouse_btns, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }
      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfInString_block()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 IfInString, Haystack, jklm
                                 {
                                    Sleep, 10
                                    FileAppend, found, *
                                 }
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 if InStr(Haystack, "jklm")
                                 {
                                    Sleep(10)
                                    FileAppend("found", "*")
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfNotInString_text()
   {
      input_script := "
         (Join`r`n
                                 Haystack = abcdefghijklmnopqrs
                                 IfNotInString, Haystack, jklm
                                    FileAppend, found, *
         )"
      expected := "
         (Join`r`n
                                 Haystack := "abcdefghijklmnopqrs"
                                 if !InStr(Haystack, "jklm")
                                    FileAppend("found", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfExist()
   {
      input_script := "
         (Join`r`n
                                 IfExist, C:\
                                    FileAppend, the drive exists, *
         )"
      expected := "
         (Join`r`n
                                 if FileExist("C:\")
                                    FileAppend("the drive exists", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfNotExist()
   {
      input_script := "
         (Join`r`n
                                 IfNotExist, W:\
                                    FileAppend, the drive doesn't exist, *
         )"
      expected := "
         (Join`r`n
                                 if !FileExist("W:\")
                                    FileAppend("the drive doesn't exist", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfWinExist()
   {
      input_script := "
         (Join`r`n
                                 IfWinExist, ahk_class Notepad
                                    FileAppend, notepad is open, *
                                 else
                                    FileAppend, notepad is not open, *
         )"
      expected := "
         (Join`r`n
                                 if WinExist("ahk_class Notepad")
                                    FileAppend("notepad is open", "*")
                                 else
                                    FileAppend("notepad is not open", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfWinNotExist()
   {
      input_script := "
         (Join`r`n
                                 IfWinNotExist, ahk_class Notepad
                                    FileAppend, notepad is not open, *
                                 else
                                    FileAppend, notepad is open, *
         )"
      expected := "
         (Join`r`n
                                 if !WinExist("ahk_class Notepad")
                                    FileAppend("notepad is not open", "*")
                                 else
                                    FileAppend("notepad is open", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfWinActive()
   {
      input_script := "
         (Join`r`n
                                 IfWinActive, ahk_class Notepad
                                    FileAppend, notepad is Active, *
                                 else
                                    FileAppend, notepad is not Active, *
         )"
      expected := "
         (Join`r`n
                                 if WinActive("ahk_class Notepad")
                                    FileAppend("notepad is Active", "*")
                                 else
                                    FileAppend("notepad is not Active", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfWinActive_emptyparams()
   {
      input_script := "
         (Join`r`n
                                 IfWinActive
                                    FileAppend, last found window is Active, *
                                 else
                                    FileAppend, last found window is not Active, *
         )"
      expected := "
         (Join`r`n
                                 if WinActive()
                                    FileAppend("last found window is Active", "*")
                                 else
                                    FileAppend("last found window is not Active", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfWinNotActive()
   {
      input_script := "
         (Join`r`n
                                 IfWinNotActive, ahk_class Notepad
                                    FileAppend, notepad is not Active, *
                                 else
                                    FileAppend, notepad is Active, *
         )"
      expected := "
         (Join`r`n
                                 if !WinActive("ahk_class Notepad")
                                    FileAppend("notepad is not Active", "*")
                                 else
                                    FileAppend("notepad is Active", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileCopyDir()
   {
      input_script := "
         (Join`r`n
                                 FileCopyDir, C:\My Folder, C:\Copy of My Folder
                                 FileCopyDir, C:\My Folder, C:\Copy of My Folder, 0
         )"
      expected := "
         (Join`r`n
                                 DirCopy("C:\My Folder", "C:\Copy of My Folder")
                                 DirCopy("C:\My Folder", "C:\Copy of My Folder", 0)
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileCreateDir()
   {
      input_script := "
         (Join`r`n
                                 FileCreateDir, C:\My Folder
         )"
      expected := "
         (Join`r`n
                                 DirCreate("C:\My Folder")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileMoveDir()
   {
      input_script := "
         (Join`r`n
                                 FileMoveDir, C:\My Folder, C:\Copy of My Folder
                                 FileMoveDir, C:\My Folder, C:\Copy of My Folder, 0
         )"
      expected := "
         (Join`r`n
                                 DirMove("C:\My Folder", "C:\Copy of My Folder")
                                 DirMove("C:\My Folder", "C:\Copy of My Folder", 0)
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileRemoveDir()
   {
      input_script := "
         (Join`r`n
                                 FileRemoveDir, C:\My Folder
                                 FileRemoveDir, C:\My Folder, 0
         )"
      expected := "
         (Join`r`n
                                 DirDelete("C:\My Folder")
                                 DirDelete("C:\My Folder", 0)
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileSelectFolder()
   {
      input_script := "
         (Join`r`n
                                 FileSelectFolder, outputvar
                                 FileSelectFolder, outputvar, C:\
                                 FileSelectFolder, outputvar, , 3
         )"
      expected := "
         (Join`r`n
                                 outputvar := DirSelect()
                                 outputvar := DirSelect("C:\")
                                 outputvar := DirSelect(, 3)
         )"
      ; first test that our expected code actually produces the same results in v2
      ; if (this.test_exec = true) {
         ; result_input    := ExecScript_v1(input_script)
         ; result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         ; Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      ; }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FileSelectFile()
   {
      input_script := "
         (Join`r`n
                                 FileSelectFile, outputvar
                                 FileSelectFile, SelectedFile, 3, , Open a file, Text Documents (*.txt`; *.doc)
         )"
      expected := "
         (Join`r`n
                                 outputvar := FileSelect()
                                 SelectedFile := FileSelect(3, "", "Open a file", "Text Documents (*.txt`; *.doc)")
         )"
      ; first test that our expected code actually produces the same results in v2
      ; if (this.test_exec = true) {
         ; result_input    := ExecScript_v1(input_script)
         ; result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         ; Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      ; }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   FormatTime()
   {
      input_script := "
         (Join`r`n
                                 FormatTime, TimeString,, Time
                                 FileAppend, the current time is %TimeString%, *
         )"
      expected := "
         (Join`r`n
                                 TimeString := FormatTime(, "Time")
                                 FileAppend("the current time is " TimeString, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      ; if (this.test_exec = true) {
         ; result_input    := ExecScript_v1(input_script)
         ; result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         ; Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      ; }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }


   IfBetween()
   {
      input_script := "
         (Join`r`n
                                 var = 3.1415
                                 if var between 5 and 10
                                    FileAppend, %var% between 5 and 10, *
                                 else if var between 1 and 4
                                    FileAppend, %var% between 1 and 4, *
         )"
      expected := "
         (Join`r`n
                                 var := "3.1415"
                                 if (var >= 5 && var <= 10)
                                    FileAppend(var " between 5 and 10", "*")
                                 else if (var >= 1 && var <= 4)
                                    FileAppend(var " between 1 and 4", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfBetweenNot()
   {
      input_script := "
         (Join`r`n
                                 var = 3.1415
                                 if var not between 0.0 and 1.0
                                    FileAppend, %var% not between 0.0 and 1.0, *
                                 else if var not between 1 and 4
                                    FileAppend, %var% not between 1 and 4, *
         )"
      expected := "
         (Join`r`n
                                 var := "3.1415"
                                 if !(var >= 0.0 && var <= 1.0)
                                    FileAppend(var " not between 0.0 and 1.0", "*")
                                 else if !(var >= 1 && var <= 4)
                                    FileAppend(var " not between 1 and 4", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfBetweenVars()
   {
      input_script := "
         (Join`r`n
                                 var = 3.1415
                                 varLow = 2
                                 varHigh = 4
                                 if var between %VarLow% and %VarHigh%
                                    FileAppend, %var% between %VarLow% and %VarHigh%, *
         )"
      expected := "
         (Join`r`n
                                 var := "3.1415"
                                 varLow := "2"
                                 varHigh := "4"
                                 if (var >= VarLow && var <= VarHigh)
                                    FileAppend(var " between " VarLow " and " VarHigh, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   IfBetweenAlphabetically()
   {
      input_script := "
         (Join`r`n
                                 var = boy
                                 if var between blue and red
                                    FileAppend, %var% is alphabetically between 'blue' and 'red', *
         )"
      expected := "
         (Join`r`n
                                 var := "boy"
                                 if ((StrCompare(var, "blue") >= 0) && (StrCompare(var, "red") <= 0))
                                    FileAppend(var " is alphabetically between 'blue' and 'red'", "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   RenameVars()
   {
      input_script := "
         (Join`r`n
                                 RunWait, %comspec% /c dir c:\
         )"
      expected := "
         (Join`r`n
                                 RunWait(A_ComSpec " /c dir c:\")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   RenameVarsOrder()
   {
      input_script := "
         (Join`r`n
                                 Loop, Files, Yunit\*.*
                                 {
                                    FileAppend, %A_LoopFileFullPath%``n%A_LoopFileLongPath%, *
                                    break
                                 }
         )"
      expected := "
         (Join`r`n
                                 Loop Files, "Yunit\*.*"
                                 {
                                    FileAppend(A_LoopFilePath "``n" A_LoopFileFullPath, "*")
                                    break
                                 }
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   RenameFunc()
   {
      input_script := "
         (Join`r`n
                                 FileAppend, % Asc("t"), *
         )"
      expected := "
         (Join`r`n
                                 FileAppend(Ord("t"), "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   RenameMultiple()
   {
      input_script := "
         (Join`r`n
                                 FileAppend, % (true) ? Asc("t") . ComSpec : Asc("w") . ComSpec, *
         )"
      expected := "
         (Join`r`n
                                 FileAppend((true) ? Ord("t") . A_ComSpec : Ord("w") . A_ComSpec, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   EscapedCommas()
   {
      input_script := "
         (Join`r`n
                                 list := "one,two,three"
                                 StringReplace list, list, ``,, ``,, UseErrorLevel
                                 FileAppend, %ErrorLevel%, *
         )"
      expected := "
         (Join`r`n
                                 list := "one,two,three"
                                 ; V1toV2: StrReplace() is not case sensitive
                                 ; check for StringCaseSense in v1 source script
                                 ; and change the CaseSense param in StrReplace() if necessary
                                 list := StrReplace(list, ",", ",",, &ErrorLevel)
                                 FileAppend(ErrorLevel, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   Sort()
   {
      input_script := "
         (Join`r`n
                                 MyVar = 5,3,7,9,1,13,999,-4
                                 Sort, MyVar, N D,  ; Sort numerically, use comma as delimiter.
                                 FileAppend, %MyVar%, *
         )"
      expected := "
         (Join`r`n
                                 MyVar := "5,3,7,9,1,13,999,-4"
                                 MyVar := Sort(MyVar, "N D,")  ; Sort numerically, use comma as delimiter.
                                 FileAppend(MyVar, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   SplitPath()
   {
      input_script := "
         (Join`r`n
                                 name := dir := ""
                                 FullFileName = C:\My Documents\Address List.txt
                                 SplitPath, FullFileName, name
                                 SplitPath, FullFileName, , dir
                                 FileAppend, %name%``n%dir%, *
         )"
      expected := "
         (Join`r`n
                                 name := dir := ""
                                 FullFileName := "C:\My Documents\Address List.txt"
                                 SplitPath(FullFileName, &name)
                                 SplitPath(FullFileName, , &dir)
                                 FileAppend(name "``n" dir, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   SplitPath_expr_var()
   {
      input_script := "
         (Join`r`n
                                 name := dir := ""
                                 FullFileName = C:\My Documents\Address List.txt
                                 SplitPath, % FullFileName, name
                                 SplitPath, % FullFileName, , dir
                                 FileAppend, %name%``n%dir%, *
         )"
      expected := "
         (Join`r`n
                                 name := dir := ""
                                 FullFileName := "C:\My Documents\Address List.txt"
                                 SplitPath(FullFileName, &name)
                                 SplitPath(FullFileName, , &dir)
                                 FileAppend(name "``n" dir, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   SplitPath_expr_str()
   {
      input_script := "
         (Join`r`n
                                 name := dir := ""
                                 SplitPath, % "C:\My Documents\Address List.txt", name
                                 SplitPath, % "C:\My Documents\Address List.txt", , dir
                                 FileAppend, %name%``n%dir%, *
         )"
      expected := "
         (Join`r`n
                                 name := dir := ""
                                 SplitPath("C:\My Documents\Address List.txt", &name)
                                 SplitPath("C:\My Documents\Address List.txt", , &dir)
                                 FileAppend(name "``n" dir, "*")
         )"
      ; first test that our expected code actually produces the same results in v2
      if (this.test_exec = true) {
         result_input    := ExecScript_v1(input_script)
         result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         Yunit.assert(result_input = result_expected, "v1 execution != v2 execution")
      }

      ; then test that our converter will correctly covert the input_script to the expected script
      converted := Convert(input_script)
      ; ViewStringDiff(expected, converted)
      Yunit.assert(converted = expected, "converted script != expected script")
   }
}


class ToExpTests
{
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

   QuotesAndPercents()
   {
      ; "hello" %A_Index%
      ; "`"hello`" " . A_Index
      orig := "`"hello`" `%A_Index`%"
      expected := "`"```"hello```" `" A_Index"
      converted := ToExp(orig)
      ;Msgbox, expected: %expected%`nconverted: %converted%
      Yunit.assert(converted = expected)
   }

   RemovePercents()
   {
      Yunit.assert(ToExp("`%hello`%") = "hello")
      Yunit.assert(ToExp("`%hello`%world") = "hello `"world`"")
      Yunit.assert(ToExp("`%hello`% world") = "hello `" world`"")
      Yunit.assert(ToExp("one `%two`% three") = "`"one `" two `" three`"")
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

   QuotesAndPercents()
   {
      ; "hello" %A_Index%
      ; "`"hello`" " . A_Index
      orig := "`"hello`" `%A_Index`%"
      expected := "`"```"hello```" `" . A_Index"
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



class RemoveSurroundingQuotesTests
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


class RemoveSurroundingPercentsTests
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
         (Join`r`n
                                 var = hello world
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hello world"
                                 FileAppend(var, "*")
         )"
      ; if (this.test_exec = true) {
         ; result_input    := ExecScript_v1(input_script)
         ; result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         ; Yunit.assert(result_input = result_expected)
      ; }
   }

   NotEquals()
   {
      input_script := "
         (Join`r`n
                                 var = hello world
                                 FileAppend, %var%, *
         )"
      expected := "
         (Join`r`n
                                 var := "hello world "
                                 FileAppend(var, "*")
         )"
      ; if (this.test_exec = true) {
         ; result_input    := ExecScript_v1(input_script)
         ; result_expected := ExecScript_v2(expected)
         ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
         ; Yunit.assert(result_input != result_expected)
      ; }
   }
}

class BoxTests
{
   ; we pipe the output of FileAppend to StdOutput
   ; then ExecScript() executes the script and reads from StdOut
   InputBox1(){
      input_script := "
         (Join`r`n `
InputBox, password, Enter Password, (your input will be hidden), hide
         )"

      expected := "
         (Join`r`n
IB := InputBox("(your input will be hidden)", "Enter Password", "Password"), password := IB.Value
         )"

      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   MsgBox1Parameter()
   {
      input_script := "
         (Join`r`n
            MsgBox This is the 1-parameter method. Commas (,) do not need to be escaped.
         )"

      expected := "
         (Join`r`n
            MsgBox("This is the 1-parameter method. Commas (,) do not need to be escaped.")
         )"

      ; if (this.test_exec = true) {
      ; result_input    := ExecScript_v1(input_script)
      ; result_expected := ExecScript_v2(expected)
      ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
      ; Yunit.assert(result_input = result_expected)
      ; }
      converted := Convert(input_script)
      if (expected!=converted){
         ViewStringDiff(expected, converted)
      }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   MsgBox1ParameterContinuationSection()
   {
      input_script := "
         (Join`r`n
MsgBox,
`(
This is the 1-parameter method. Commas (,) do not need to be escaped.
With continuation section.
`)
      )"

      expected := "
         (Join`r`n
MsgBox
`(
"This is the 1-parameter method. Commas (,) do not need to be escaped.
With continuation section."
`)
)"

      ; if (this.test_exec = true) {
      ; result_input    := ExecScript_v1(input_script)
      ; result_expected := ExecScript_v2(expected)
      ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
      ; Yunit.assert(result_input = result_expected)
      ; }
      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   MsgBox3Parameter()
   {
      input_script := "
         (Join`r`n
MsgBox, 4, , This is the 3-parameter method. Commas (,) do not need to be escaped.
         )"

      expected := "
         (Join`r`n
MsgBox("This is the 3-parameter method. Commas (,) do not need to be escaped.", "", 4)
         )"

      ; if (this.test_exec = true) {
      ; result_input    := ExecScript_v1(input_script)
      ; result_expected := ExecScript_v2(expected)
      ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
      ; Yunit.assert(result_input = result_expected)
      ; }
      converted := Convert(input_script)
      if (expected!=converted){
         ViewStringDiff(expected, converted)
      }
      Yunit.assert(converted = expected, "converted script != expected script")
   }


   MsgBox4Parameter()
   {
      input_script := "
         (Join`r`n
MsgBox, 4, , 4-parameter method: this MsgBox will time out in 5 seconds.  Continue?, 5
         )"

      expected := "
         (Join`r`n
MsgBox("4-parameter method: this MsgBox will time out in 5 seconds.  Continue?", "", "4 T5")
         )"

      ; if (this.test_exec = true) {
      ; result_input    := ExecScript_v1(input_script)
      ; result_expected := ExecScript_v2(expected)
      ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
      ; Yunit.assert(result_input = result_expected)
      ; }
      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }


}


class GuiTests
{
   ; we pipe the output of FileAppend to StdOutput
   ; then ExecScript() executes the script and reads from StdOut

   GuiExample1()
   {
      input_script := "
         (Join`r`n
            Gui, Add, Text,, Please enter your name:
            Gui, Add, Edit, vName
            Gui, Show
         )"

      expected := "
         (Join`r`n
            myGui := Gui()
            myGui.Add("Text", , "Please enter your name:")
            ogcEditName := myGui.Add("Edit", "vName")
            myGui.Show()
         )"

      ; if (this.test_exec = true) {
      ; result_input    := ExecScript_v1(input_script)
      ; result_expected := ExecScript_v2(expected)
      ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
      ; Yunit.assert(result_input = result_expected)
      ; }
      converted := Convert(input_script)
      if (expected!=converted){
         ; ViewStringDiff(expected, converted)
      }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   GuiExample2()
   {
      input_script := "
         (Join`r`n
Gui, +AlwaysOnTop +Disabled -SysMenu +Owner  ; +Owner avoids a taskbar button.
Gui, Add, Text,, Some text to display.
Gui, Show, NoActivate, Title of Window  ; NoActivate avoids deactivating the currently active window.
         )"

      expected := "
         (Join`r`n
myGui := Gui()
myGui.Opt("+AlwaysOnTop +Disabled -SysMenu +Owner")  ; +Owner avoids a taskbar button.
myGui.Add("Text", , "Some text to display.")
myGui.Title := "Title of Window"
myGui.Show("NoActivate")  ; NoActivate avoids deactivating the currently active window.
         )"


      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }


}

class MenuTests
{
   ; we pipe the output of FileAppend to StdOutput
   ; then ExecScript() executes the script and reads from StdOut

   MenuExample1()
   {
      input_script := "
         (Join`r`n
Menu, Tray, Add  ; Creates a separator line.
Menu, Tray, Add, Item1, MenuHandler  ; Creates a new menu item.
         )"

      expected := "
         (Join`r`n
Tray:= A_TrayMenu
Tray.Add()  ; Creates a separator line.
Tray.Add("Item1", MenuHandler)  ; Creates a new menu item.
         )"

      ; if (this.test_exec = true) {
      ; result_input    := ExecScript_v1(input_script)
      ; result_expected := ExecScript_v2(expected)
      ; MsgBox("'input_script' results (v1):`n[" result_input "]`n`n'expected' results (v2):`n[" result_expected "]")
      ; Yunit.assert(result_input = result_expected)
      ; }
      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }
}

class FlowTests
{

   loopNormal()
   {
      input_script := "
         (Join`r`n
Loop, 3
{
    MsgBox, Iteration number is %A_Index%.  ; A_Index will be 1, 2, then 3
    Sleep, 100
}
         )"

      expected := "
         (Join`r`n
Loop 3
{
    MsgBox("Iteration number is " A_Index ".")  ; A_Index will be 1, 2, then 3
    Sleep(100)
}
         )"

      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   LoopParse1(){
      input_script := "
         (Join`r`n
Colors := "red,green,blue"
Loop, parse, Colors, ``,
{
    MsgBox, Color number %A_Index% is %A_LoopField%.
}
         )"

      expected := "
         (Join`r`n
Colors := "red,green,blue"
Loop parse, Colors, ","
{
    MsgBox("Color number " A_Index " is " A_LoopField ".")
}
         )"

      converted := Convert(input_script)
      DebugWindow("converted:`n"  converted "`n")
DebugWindow("expected:`n"  expected "`n")
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

   LoopParse2(){
      input_script := "
         (Join`r`n
Loop, parse, clipboard, ``n, ``r
{
    MsgBox, 4, , File number %A_Index% is %A_LoopField%.``n``nContinue?
    IfMsgBox, No, break
}
         )"

      expected := "
         (Join`r`n
Loop parse, A_Clipboard, "``n", "``r"
{
    msgResult := MsgBox("File number " A_Index " is " A_LoopField ".``n``nContinue?", "", 4)
    if (msgResult = "No")
        break
}
         )"

      converted := Convert(input_script)

      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

}

class WinTests
{
   WinGetTitle(){
      input_script := "
         (Join`r`n `
WinGetTitle, Title, A
         )"

      expected := "
         (Join`r`n
Title := WinGetTitle("A")
         )"

      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }

}

ViewStringDiff(expected, converted)
{
   FileAppend(expected, "expected.txt")
   FileAppend(converted, "converted.txt")
   RunWait('..\diff\VisualDiff.exe ..\diff\VisualDiff.ahk "' . A_ScriptDir . '\expected.txt" "' . A_ScriptDir . '\converted.txt"')
   FileDelete("expected.txt")
   FileDelete("converted.txt")
}

