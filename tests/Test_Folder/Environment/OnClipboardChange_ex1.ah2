Persistent
OnClipboardChange(ClipChanged)
return

ClipChanged(Type) {
    ToolTip("Clipboard data type: " Type)
    Sleep(1000)
    ToolTip()  ; Turn off the tip.
}