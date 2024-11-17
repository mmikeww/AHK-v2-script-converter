; V1toV2: Some mandatory VarRefs replaced with AHKv1v2_vPlaceholder
ErrorLevel := !PixelSearch(&AHKv1v2_vPlaceholder, &AHKv1v2_vPlaceholder, CenterX, 1, CenterX, 1, 0xF3F3F3) ; V1toV2: Converted colour to RGB format
if (Errorlevel == 1) {
    MsgBox("Colour not found")
}