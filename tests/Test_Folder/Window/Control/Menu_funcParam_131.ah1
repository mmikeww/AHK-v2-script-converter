Menu, Image, Add, Invert colours of image in clipboard, InvertImageInCb
Menu, Image, Add, Save Clipboard Image as File, SaveCbImageasFile
Menu, Image, Add, Save Clipboard Image as 8-bit PNG, SaveCbImageas8Bit

; Issue #131
; * param needs to be added to funcs

InvertImageInCb() {

    RunWait, magick.exe convert clipboard:myimage -channel RGB -negate -background white -flatten clipboard:, , Hide
    MsgBox, Inverted colors of image in clipboard.
}

SaveCbImageasFile(param1) { ; comment

    RunWait, magick.exe convert clipboard:myimage -channel RGB -negate -background white -flatten clipboard:, , Hide
    MsgBox, Inverted colors of image in clipboard.
}

SaveCbImageas8Bit(param1, param2, param3) {

    RunWait, magick.exe convert clipboard:myimage -channel RGB -negate -background white -flatten clipboard:, , Hide
    MsgBox, Inverted colors of image in clipboard.
}