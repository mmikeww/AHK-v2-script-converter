; from the 'Run' help docs:

; ExecScript: Executes the given code as a new AutoHotkey process.

; we will use this to test that the v1 -> v2 conversion actually works in v2


ExecScript_v1(Script, Wait:=true)
{
    shell := ComObject("WScript.Shell")
    exec := shell.Exec("..\AutoHotKey Exe\AutoHotkeyV1.exe /ErrorStdOut *")
    exec.StdIn.Write(Script)
    exec.StdIn.Close()
    if Wait
        return exec.StdOut.ReadAll()
}


ExecScript_v2(Script, Wait:=true)
{
    shell := ComObject("WScript.Shell")
    exec := shell.Exec("..\AutoHotKey Exe\AutoHotkeyV2.exe /ErrorStdOut *")
    exec.StdIn.Write(Script)
    exec.StdIn.Close()
    if Wait
        return exec.StdOut.ReadAll()
}


