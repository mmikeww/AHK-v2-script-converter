
;################################################################################
; line objects hold orig line string, as well as the converted version
;	can be multi-line
;	TODO - track what kind of data is within line ?
;		gui related?, has comment?, variables?, func calls?, expression or legacy? ahk command found?
Class Cls_Line
{
	_lineNum		:= -1
	_origCode		:= ''
	_convCode		:= ''
	_lineComment	:= ''
	;############################################################################
	__New(lineCode)
	{
		this._origCode := lineCode
	}
	;############################################################################
	; Public properties
	OrigCode => this._origCode
	ConvCode {
		get => this._convCode
		set {
			this._convCode := value
		}
	}
}
;################################################################################
;################################################################################
Class Cls_Conversion
{
	_origCode		:= ''
	_LinesArr		:= []
	ConvertCode		=> this._convertCode()		 											; convert code and return final converted string
	ConvertedCode	=> this._getConvertedStr()
	;############################################################################
	__New(code)
	{
		this._origCode := code
		this._prepCode()
	}
	;############################################################################
	; performs conversion process
	_convertCode()
	{
		for idx, lineObj in this._LinesArr {
			lineObj.ConvCode := this._lineConversion(lineObj.Origcode)
		}
		return this.ConvertedCode
		/*
			perform steps on block as a whole
				prepCode()

			create new line object for each line
				expand mask tags?
				split line into logical parts
				perform multiple checks and conversions for line
				place converted version
		*/
	}
	;############################################################################
	; conversion steps
	_lineConversion(lineStr)
	{
		return toExpEquals(lineStr)
	}
	;############################################################################
	; returns final converted string
	; extracts all converted line strings (from line objects held in LinesArr)...
	; combines them to form the final converted string for final output
	_getConvertedStr()
	{
		; extract and combine strings from LinesArr
		retStr := ''
		for idx, lineObj in this._LinesArr {
			retStr .= lineObj.convCode '`r`n'
		}
		return retStr
	}
	;############################################################################
	_prepCode()
	{
		this._getLines()
		/*
			mask block comments
			mask all line comments?
			mask strings?
			mask classes?
			mask functions?
			mask function calls?
			mask multi-lines
			split lines into LinesArr[] containing Line-objects
				see Line Class for details
		*/
	}
	;############################################################################
	_getLines()
	{
		lines := StrSplit(this._origCode, '`n', '`r')
		for idx, line in lines
		{
			lineObj := 	Cls_Line(line)
			this._LinesArr.push(lineObj)
		}
	}
}
;################################################################################
;################################################################################
Class ConvertV1 extends Cls_Conversion
{
	; OVERRIDES same method in parent
	_convertCode()
	{
	}
}
;################################################################################
;################################################################################
Class ConvertV2 extends Cls_Conversion
{
	; OVERRIDES same method in parent
	_convertCode()
	{
	}
}
;################################################################################
;################################################################################
toExpEquals(code)
{
	retCode := ''
	if (RegExMatch(code, "(?i)^(\h*[a-z_%][a-z_0-9%]*\h*)=([^;\v]*)", &m)) {
		retCode := RTrim(m[1]) . " := " . ToExp(m[2],,1)									; regex above keeps the gIndent already
	}
	return retCode
}