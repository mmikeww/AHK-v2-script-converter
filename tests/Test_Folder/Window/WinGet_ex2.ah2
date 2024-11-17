oid := WinGetList(,,"Program Manager",)
aid := Array()
id := oid.Length
For v in oid
{   aid.Push(v)
}
Loop aid.Length
{
    this_id := aid[A_Index]
    WinActivate("ahk_id " this_id)
    this_class := WinGetClass("ahk_id " this_id)
    this_title := WinGetTitle("ahk_id " this_id)
    msgResult := MsgBox("Visiting All Windows`n" A_Index " of " aid.Length "`nahk_id " this_id "`nahk_class " this_class "`n" this_title "`n`nContinue?", "", 4)
    if (msgResult = "NO")
        break
}