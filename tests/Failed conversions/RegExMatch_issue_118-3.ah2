
a(s, r) {
    RegExMatch(s, r, &m)
    a := (m && m[0])
    c := m[1]
    return (m && m[0])
}

; A variable in a different context is not a good fit for replacement:
b(m) {
    return m
}
