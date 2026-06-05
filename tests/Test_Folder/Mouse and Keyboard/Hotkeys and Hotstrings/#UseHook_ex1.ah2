#UseHook  ; Force the use of the hook for hotkeys after this point.
return ; V1toV2: remove if unnecessary
#x::MsgBox("This hotkey will be implemented with the hook.")
#y::MsgBox("And this one too.")
#UseHook false
return ; V1toV2: remove if unnecessary
#z::MsgBox("But not this one.")