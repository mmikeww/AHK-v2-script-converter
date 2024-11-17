~CapsLock::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
KeyWait("CapsLock")  ; Wait for user to physically release it.
MsgBox("You pressed and released the CapsLock key.")
return
} ; V1toV2: Added bracket in the end