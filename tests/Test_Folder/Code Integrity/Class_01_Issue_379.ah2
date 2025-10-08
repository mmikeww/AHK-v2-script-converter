#SingleInstance Force

obj := cls()	; will be converted to cls()
obj.showName()

class cls
{
	_name := ""
	nextObj := ""

	; v2 must have this method for v2 version of 'this()' (below) to create new objects
	call() {
		return this
	}

	showName() {
		static c:=0
		c++
		this._name := "obj " c
		MsgBox("I am new " this._name)
		if (c >= 5)
		return
		a := this()	; v2 requires call() method (above) for 'this()' to work
		a.showName()
	}
}

esc::ExitApp()