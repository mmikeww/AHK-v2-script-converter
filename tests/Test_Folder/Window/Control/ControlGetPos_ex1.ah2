Loop
{
    Sleep(100)
    MouseGetPos(, , &WhichWindow, &WhichControl)
    ControlGetPos(&x, &y, &w, &h, WhichControl, "ahk_id " WhichWindow)
    ToolTip(WhichControl "`nX" X "`tY" Y "`nW" W "`t" H)
}