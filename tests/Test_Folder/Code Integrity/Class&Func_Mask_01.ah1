
#SingleInstance Force

normalFunc1(1)

normalFunc1(a)
{
;	a := "this is a test"
	msgbox % a	; testing
	msgbox % "hello1"
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
			msgbox % "hello11"
			msgbox % yo
		}
	}

	class nesty2 extends dum
	{
		static member1 := 1
		member3 := 3

		method111()
		{
			yo := "yoyo"
			msgbox % "hello11"
			msgbox % yo
		}

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

	}

	method11()
	{
		yo := "yoyo"
		msgbox % "hello11"
		msgbox % yo
	}

	method21()
	{
		msgbox % "hello21"	; testing comment
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
		msgbox % "hello21"
	}

	method22()
	{
		msgbox % "hello22"
	}
}


normalFunc2(b)	; comment func2
{
	msgbox % b	; comment b
}