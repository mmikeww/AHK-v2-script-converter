
; fixes for truncation and false positives

guicontrol, move, MyLV, y50 w20 x400

guicontrol, move, MyLV, w%width% h%height%  ; width/height no longer truncated

guicontrol, move, MyLV, " w" halfWidth  ; halfWidth no longer causes false-positive for h param

guicontrol, move, MyLV, "x" x " w" yes this.is[(width())] " h" height + 1.5

guiControl, move, MyLV, % "h" (1 - vol*mastervol) * 300