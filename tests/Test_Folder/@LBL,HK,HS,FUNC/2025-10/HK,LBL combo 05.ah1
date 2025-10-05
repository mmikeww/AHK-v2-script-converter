

return
MouseClickHandler: ; label comes before HK triggers
    MsgBox % "MouseClickHandler"
    return

^LButton::Gosub, MouseClickHandler ; Single-line gosub
Return

^RButton::
Gosub, MouseClickHandler ; Multi-line gosub
Return
