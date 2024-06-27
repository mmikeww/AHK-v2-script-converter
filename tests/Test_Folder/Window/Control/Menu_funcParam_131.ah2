Image := Menu()
Image.Add("Invert colours of image in clipboard", InvertImageInCb)
Image.Add("Save Clipboard Image as File", SaveCbImageasFile)
Image.Add("Save Clipboard Image as 8-bit PNG", SaveCbImageas8Bit)

; Issue #131
; * param needs to be added to funcs

InvertImageInCb(*) {

    RunWait("magick.exe convert clipboard:myimage -channel RGB -negate -background white -flatten clipboard:", , "Hide")
    MsgBox("Inverted colors of image in clipboard.")
}

SaveCbImageasFile(*) {

    RunWait("magick.exe convert clipboard:myimage -channel RGB -negate -background white -flatten clipboard:", , "Hide")
    MsgBox("Inverted colors of image in clipboard.")
}

SaveCbImageas8Bit(*) {

    RunWait("magick.exe convert clipboard:myimage -channel RGB -negate -background white -flatten clipboard:", , "Hide")
    MsgBox("Inverted colors of image in clipboard.")
}