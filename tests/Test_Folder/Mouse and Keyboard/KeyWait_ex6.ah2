*NumpadAdd::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MouseClick("left", , , 1, 0, "D")  ; Hold down the left mouse button.
KeyWait("NumpadAdd")  ; Wait for the key to be released.
MouseClick("left", , , 1, 0, "U")  ; Release the mouse button.
return
} ; V1toV2: Added bracket in the end