; fix for func params not being updated when label text-case does not match AHK map key

gui, font, s12
var:="test"
gui, add, text,  vtxt center, % var
gui, show
return

guiclose:
ExitApp
return