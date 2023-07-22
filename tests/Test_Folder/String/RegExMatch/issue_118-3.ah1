
a(s, r) {
    RegExMatch(s, r, m)
    a := m
    b := m1
    return m
}

; A variable in a different context is not a good fit for replacement:
b(m) {
    return m
}
