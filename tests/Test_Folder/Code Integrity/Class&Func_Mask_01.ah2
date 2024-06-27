
#SingleInstance Force

normalFunc1(1)

normalFunc1(a)
{
;	a := "this is a test"
	MsgBox(a)	; testing
	MsgBox("hello1")
}

class dum
{
}

Class dummy1 extends dum	; class comment 1
; class comment 2
{
; class comment3

	static member1 := 1
	member2 := 2

	__new(var1)
	{
		this.member2 := "member2"
	}

	class nesty1 extends dum
	{
		static member1 := 1
		member2 := 2

		method111()
		{
			yo := "yoyo"
			MsgBox("hello11")
			MsgBox(yo)
		}
	}

	class nesty2 extends dum
	{
		static member1 := 1
		member3 := 3

		method111()
		{
			yo := "yoyo"
			MsgBox("hello11")
			MsgBox(yo)
		}

		a(s, r) {
			RegExMatch(s, r, &m)
			a := (m&&m[0])
			b := m[1]
			return (m&&m[0])
		}

		; A variable in a different context is not a good fit for replacement:
		b(m) {
			return m
		}

	}

	method11()
	{
		yo := "yoyo"
		MsgBox("hello11")
		MsgBox(yo)
	}

	method21()
	{
		MsgBox("hello21")	; testing comment
	}
	
	; A variable in a different context is not a good fit for replacement:
	b(m) {
		return m
	}

}

Class dummy2 extends dum
{
	method21()	; comment 21a
	{
		; comment 21b
		MsgBox("hello21")
	}

	method22()
	{
		MsgBox("hello22")
	}
}


normalFunc2(b)	; comment func2
{
	MsgBox(b)	; comment b
}