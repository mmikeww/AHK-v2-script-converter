Yunit
=====
Super simple testing framework for AutoHotkey.

Yunit is designed to aid in the following tasks:

* Automated code testing.
* Automated benchmarking.
* Basic result reporting and collation.
* Test management.

Example
-------
See [doc/Example.ahk](Example.ahk) for a working example script that demonstrates Yunit being used for testing.

A basic test setup looks like the following:

    Yunit.Use(YunitStdout).Test(TestSuite)
    
    class TestSuite
    {
        SomeTest()
        {
            return True
        }
    }

Installation
------------
Installation is simply a matter of adding the Yunit folder to the library path of your project.

An example directory structure is shown below:

    + SomeProject
    |    + Lib
    |    |    + Yunit
    |    |    |    LICENSE.txt
    |    |    |    README.md
    |    |    |    ...
    |    |    + OtherLibrary
    |    |    |    ...
    |    README.md
    |    SomeProject.ahk
    |    ...

In AutoHotkey v1.1, library locations are checked as follows:

1. Local library: %A_ScriptDir%\Lib\
2. User library: %A_MyDocuments%\Lib\
3. Standard library: %A_AhkPath%\Lib\

Importing
---------
Yunit and its modules must be imported to be used:

    #Include <Yunit\Yunit> ;import the basic test routines (mandatory)
    #Include <Yunit\Window> ;import the window output module (optional)
    #Include <Yunit\Stdout> ;import the stdout output module (optional)
    #Include <Yunit\OutputDebug> ;import the OutputDebug output module (optional)
    #Include <Yunit\JUnit> ;import the JUnit output module (optional)

Output modules only need to be imported if they are going to be used.

Usage
-----
Yunit is implemented as a class, conveniently named `Yunit`.
This class is static, which basically means you do not need to make a new instance of `Yunit` it to use it.

To begin, first we need to select the output modules to use (a list of available modules is documented in the *Modules* section below).
In other words, where the results of the tests should go.

This is done using the `Yunit.Use(Modules*)` method, where `Modules*` represents zero or more modules to use.
When called, the method returns a `Yunit.Tester` object, which represents the options and settings for a group of tests:

    Tester := Yunit.Use(YunitStdout, YunitWindow)

This code creates a `Yunit.Tester` object that uses the `YunitStdout` and `YunitWindow` modules for output.

Now that the `Yunit.Tester` object has been created, we can run a set of tests against it.
This is done using the `Yunit.Tester.Test(Classes*)` method, where `Classes*` represents zero or more test classes to use (the format is documented in the *Tests* section below).
When called, the method starts the tests and manages the results:

    Tester.Test(FirstTestSet, SecondTestSet, ThirdTestSet)

This code runs all tests in all three sets.

This method is synchronous and blocks the current thread until complete.
Results will be shown while the method is running.

Instead of using the two lines above, it may be preferable to simply chain them together:

    Yunit.Use(YunitStdout, YunitWindow).Test(FirstTestSet, SecondTestSet, ThirdTestSet)

Modules
-------
Multiple output modules are available:

### YunitStdout

    Tester := Yunit.Use(YunitStdout)

This module writes the test results to the standard output. To see the output, use [this](https://autohotkey.com/docs/commands/FileAppend.htm) at the command prompt:

`"%ProgramFiles%\AutoHotkey\AutoHotkey.exe" "TestsScript.ahk" | more`

The results are formatted one per line, each entry being in the following form:

    Result: Category.TestName Data

* _Result_ - result of the test ("PASS" or "FAIL").
* _Category_ - category or categories that the test is located under, with subcategories separated by dots (Category.Subcategory.OtherCategory).
* _TestName_ - name of the test being run.
* _Data_ - data given by the test, such as specific error messages or benchmark numbers.

### YunitOutputDebug

    Tester := Yunit.Use(YunitOutputDebug)

This module writes the test results via OutputDebug. To see the output, see how to use [OutputDebug](https://autohotkey.com/docs/commands/OutputDebug.htm)

The results are formatted one per line, each entry being in the following form:

    (Counter) Result: Category.TestName Data

* _Counter_ - Number of the performed test
* _Result_ - result of the test ("PASS" or "FAIL").
* _Category_ - category or categories that the test is located under, with subcategories separated by dots (Category.Subcategory.OtherCategory).
* _TestName_ - name of the test being run.
* _Data_ - data given by the test, such as specific error messages or benchmark numbers.

### YunitJUnit

    Tester := Yunit.Use(YunitJUnit)

This module writes the test results  JUnit compatible XML-Output. The XML-File is generated in the _directory where the Test-script_ resides and
has the name _junit.xml_.

The JUnit format is commonly used on Continuous-Integration servers (like [jenkins](https://jenkins.io/))

See [here for more information on the JUnit-format](https://pzolee.blogs.balabit.com/2012/11/jenkins-vs-junit-xml-format/)

### YunitWindow

    Tester := Yunit.Use(YunitWindow)

This module displays the test results in a window with icons showing the status of each test.

The results are shown in the form of a tree control, with each test suite having a top level node, and categories or tests having child nodes.

Beside each node is an icon:

* _Green up arrow_ - test passed successfully.
* _Yellow triangle with exclamation mark_ - test failed.
* _Two papers_ - test result/description.

Tests that result in data will have an additional child node that can be expanded to show it.

Test Suites and Categories
--------------------------
Test suites are written as classes. Class methods are considered tests; nested classes are considered categories.
Classes nested within these nested classes are considered subcategories, and so on:

    class TestSuite
    {
        This_Is_A_Test()
        {
            ;...
        }
    
        class This_Is_A_Category
        {
            This_Is_A_Test()
            {
                ;...
            }
            
            This_Is_Another_Test()
            {
                ;...
            }
        }
    }

The above corresponds to the following test structure:

    TestSuite:
        This_Is_A_Test
        This_Is_A_Category:
            This_Is_A_Test
            This_Is_Another_Test

The test and category names are determined from their identifiers in the code. Test and category names may be duplicated as long as they are in different categories.

The order in which tests are called is arbitrary.

Writing Tests
-------------
A test is a class method that takes no arguments and has no return value.
For a test to fail it must throw an Error exception. 
Any test that returns normally is considered a success. 
The method `Yunit.Assert(Value, Message)` conveniently throws an Error exception when `Value` evaluates to false, with an optional `Message` which is displayed if it fails. If the Assert() fails however, no subsequent code within the test function will execute. So, it should always be the last line within the function.

    This_Is_A_Test()
    {
        Yunit.Assert(1 = 1) ;test passes
    }
    
    This_Is_Another_Test()
    {
        Yunit.Assert(1 = 2, "Description of the failure") ;test fails
        MsgBox, hello world   ;this never runs since the test above failed
    }

The special test methods `Begin()` and `End()`, if present, will be called on the instance of the class before and after _each test_, respectively.
Use this to do setup on the `this` object for each test in a category.

In addition, the special class methods `__New()` and `__Delete()` are called before testing starts on a category and after it finishes, respectively.
