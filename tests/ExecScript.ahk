; from the 'Run' help docs:

; ExecScript: Executes the given code as a new AutoHotkey process.

; we will use this to test that the v1 -> v2 conversion actually works in v2


ExecScript_v1(Script, Wait:=true)
{
    shell := ComObject("WScript.Shell")
    ;// the VisualDiff.exe file is just a renamed AHK v1.1.24.01 exe
    exec := shell.Exec("..\diff\VisualDiff.exe /ErrorStdOut *")
    exec.StdIn.Write(Script)
    exec.StdIn.Close()
    if Wait
        return exec.StdOut.ReadAll()
}


ExecScript_v2(Script, Wait:=true)
{
    shell := ComObject("WScript.Shell")
    ;// the Tests.exe file is just a renamed AHK v2-beta.1 exe
    exec := shell.Exec("Tests.exe /ErrorStdOut *")
    exec.StdIn.Write(Script)
    exec.StdIn.Close()
    if Wait
        return exec.StdOut.ReadAll()
}


