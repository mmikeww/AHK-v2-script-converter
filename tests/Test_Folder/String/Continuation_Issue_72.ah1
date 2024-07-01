; fix for issue #72 (missing linefeeds on continuation section)
None() {
    ; Removes all events.
    return this
        .OnEvent("LeftMouseDown")
        .OnEvent("MiddleMouseDown")
        .OnEvent("RightMouseDown")
}