;############################
; description: Generate JUnit-XML output for Yunit-Framework (https://github.com/Uberi/Yunit)
;
; author: hoppfrosch
; date: 20170427
;############################
class YunitJUnit{
; implemented according http://stackoverflow.com/questions/4922867/junit-xml-format-specification-that-hudson-supports
    __new(instance)
    {
        this.filename := A_ScriptDir . "\junit.xml"
        ; the file is deleted if it exists already
        if FileExist(this.filename) {
            FileDelete this.filename
        }
				this.out := Array()
				this.tests := {}
        this.tests.pass := 0
        this.tests.fail := 0
				this.tests.overall := 0
				
        Return this
    }
  
    __Delete() {
				file := FileOpen(this.filename, "w")
				file.write('<?xml version="1.0" encoding="UTF-8"?>`n')
				msg := '<testsuites failures="' . this.tests.fail . '" tests="' . this.tests.overall . '">'
				file.write(msg . "`n")
				msg := '`t<testsuite failures="' . this.tests.fail . '" tests="' . this.tests.overall . '" name="AHK_YUnit">'
				file.write(msg . "`n")
				Loop this.out.Length
					file.write(this.out[A_Index] . "`n")
        file.write("`t</testsuite>`n")
				file.write("</testsuites>`n")
				file.close()
    }

    
    Update(Category, TestName, Result)
    {		
				this.tests.overall := this.tests.overall + 1
				msg := '`t`t<testcase name="' . TestName . '" classname="' . Category . '"'
        if Result is Error
        {
					this.out.Push(msg . ">")
					this.tests.fail := this.tests.fail + 1
          msg := "Line #" result.line ": " result.message
					this.out.Push('`t`t`t<failure message="' . msg . '" type ="failure"></failure>')
					this.out.Push("`t`t</testcase>")
        }
				Else 
        {
						this.out.Push(msg . "/>")
            this.tests.pass := this.tests.pass + 1
				}
    }
}
