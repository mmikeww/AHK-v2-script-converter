
;################################################################################
Class PseudoArray
{
; WORK IN PROGRESS

	static arrList := []

	Name := ''			; Str
	newname := ''

	strict := true		; boolean T/F - always true
	regex := true		; boolean T/F - always true
}

;################################################################################;################################################################################
;//	Example array123 => array[123]
;//	Example array%A_index% => array[A_index]
;//	Special cases in RegExMatch		=> {OutVar: OutVar[0],		OutVar0: ""				}
;//	Special cases in StringSplit	=> {OutVar: "",				OutVar0: OutVar.Length	}
;//	Special cases in WinGet(List) => {OutVar: OutVar.Length,	OutVar0: ""				}
;// Converts PseudoArray to Array
ConvertPseudoArray(ScriptStringInput, PseudoArrayName)
{
	; The caller does a fast InStr before calling.
	; Summary of suffix variations depending on sources:
	;	- StringSplit		=> OutVar:Blank		; OutVar0:Length; OutVarN:Items;
	;	- WinGet-List		=> OutVar:Length	; OutVar0:Blank;	OutVarN:Items;
	;	- RegExMatch-Mode1	=> OutVar:Text		; OutVar0:Blank;	OutVarN:Items;
	;	- RegExMatch-Mode2	=> OutVar:Length	; OutVar0:Blank;	OutVarN:Blank; OutVarPosN:Item-pos; OutVarLenN:Item-len;
	;	- RegExMatch-Mode3	=> OutVar:Object	; OutVar0:Blank;	OutVarN:Blank;

	ArrayName := PseudoArrayName.name
	NewName := PseudoArrayName.HasOwnProp("newname") ? PseudoArrayName.newname : ArrayName
	if (RegexMatch(ScriptStringInput,"i)^\h*(local|global|static)\h"))
	{
		; Expecting situations like "local x,v0,v1" to end up as "local x,v".
		ScriptStringInput := RegExReplace(ScriptStringInput, "is)\b(" ArrayName ")(\d*\s*,\s*(?1)\d*)+\b", NewName)
	}
	else if (PseudoArrayName.HasOwnProp("strict") && PseudoArrayName.strict)
	{
		; Replacement without allowing suffix.

		; 2024-06-22 AMB Added regex property to support regexmatch array validation (has it been set?)
		; see _RegExMatch() in 2Functions.ahk to see where this property is set
		if (PseudoArrayName.HasOwnProp("regex") && PseudoArrayName.regex)
		{
			; this is regexmatch array[0] - validate that array has been set -> (m&&m[0])
			Mask_T(&ScriptStringInput, 'STR')
			ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "(?!&|\w|%|\.|\[|\h*:=)", "(" ArrayName "&&" NewName ")")
			Mask_R(&ScriptStringInput, 'STR')
		}
		else
		{
			; anything other than regexmatch
			ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "(?!\w|%|\.|\[|\h*:=)", NewName)
		}
	}
	else
	{
		; General replacement for numerical suffixes and percent signs.
		ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "([1-9]\d*)(?!\w|\.|\[)", NewName "[$1]")
		ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "%(\w+)%(?!\w|\.|\[)", NewName "[$1]")
	}

	Return ScriptStringInput
}
;################################################################################
;//	Example ObjectMatch.Value(N) => ObjectMatch[N]
;//	Example ObjectMatch.Len(N) => ObjectMatch.Len[N]
;//	Example ObjectMatch.Mark() => ObjectMatch.Mark
;//	Special case ObjectMatch.Name(N) => ObjectMatch.Name(N)
;//	Special case ObjectMatch.Name => ObjectMatch["Name"]
;// Converts Object Match V1 to Object Match V2
ConvertMatchObject(ScriptStringInput, ObjectMatchName)
{
	; The caller does a fast InStr before calling.
	; We try to catch group-names before methods turn into properties.
	; ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(\d+)\b", '$1[$2]') ; Matter of preference.
	ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(?=\w*[a-z_])(\w+)(?!\w|\()", '$1["$2"]')
	ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(Value)\((.*?)\)", "$1[$3]")
	ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(Mark|Count)\(\)", "$1.$2")
	Return ScriptStringInput
}
;################################################################################
										   v2_PseudoAndRegexMatchArrays(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: Converts PseudoArray to Array and...
;	ensures v1 RegexMatchObject can be accessed as a v2 Array
/*
	V2 ONLY?	- Can part be applied to V1.1 if user wants (with exception of v2 only)?
	also ensure v1 RegexMatchObject can be accessed as a v2 Array
	array123						=> array[123]
	array%A_index%					=> array[A_index]
	Special cases in RegExMatch		=> { OutVar: OutVar[0]		OutVar0: ""				}
	Special cases in StringSplit	=> { OutVar: "",			OutVar0: OutVar.Length	}
	Special cases in WinGet(List)	=> { OutVar: OutVar.Length,	OutVar0: ""				}
*/

	; gaList_PseudoArr gets its input from
	;	_StringSplit()
	;	_WinGet()
	;	_RegExMatch()
	Loop gaList_PseudoArr.Length {
		if (InStr(lineStr, gaList_PseudoArr[A_Index].name))
			lineStr := ConvertPseudoArray(lineStr, gaList_PseudoArr[A_Index])
	}

/*
	V2 ONLY
	Converts Object Match V1 to Object Match V2
	ObjectMatch.Value(N)	=> ObjectMatch[N]
	ObjectMatch.Len(N)		=> ObjectMatch.Len[N]
	ObjectMatch.Mark()		=> ObjectMatch.Mark
	ObjectMatch.Name(N)		=> ObjectMatch.Name(N)
	ObjectMatch.Name		=> ObjectMatch["Name"]
*/
	Loop gaList_MatchObj.Length {
		if (InStr(lineStr, gaList_MatchObj[A_Index]))
			lineStr := ConvertMatchObject(lineStr, gaList_MatchObj[A_Index])
	}

	return		; lineStr by reference
}
;################################################################################
_StringSplit(p)
{
	;V1 StringSplit,OutputArray,InputVar,DelimitersT2E,OmitCharsT2E
	; Output should be checked to replace OutputArray\d to OutputArray[\d]
	global gaList_PseudoArr
	VarName := Trim(p[1])
	gaList_PseudoArr.Push({name: VarName})
	gaList_PseudoArr.Push({strict: true, name: VarName "0", newname: VarName ".Length"})
	Out := Format("{1} := StrSplit({2},{3},{4})", p*)
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_WinGet(p)
{
	global gIndent
	p[2] := p[2] = "ControlList" ? "Controls" : p[2]

	Out := format("{1} := WinGet{2}({3},{4},{5},{6})", p*)
	if (P[2] = "Class" || P[2] = "Controls" || P[2] = "ControlsHwnd" || P[2] = "ControlsHwnd") {
		Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
		Out .= gIndent "For v in o" P[1] "`r`n"
		Out .= gIndent "{`r`n"
		Out .= gIndent "   " P[1] " .= A_index=1 ? v : `"``r``n`" v`r`n"
		Out .= gIndent "}"
	}
	if (P[2] = "List") {
		Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
		Out .= gIndent "a" P[1] " := Array()`r`n"
		Out .= gIndent P[1] " := o" P[1] ".Length`r`n"
		Out .= gIndent "For v in o" P[1] "`r`n"
		Out .= gIndent "{   a" P[1] ".Push(v)`r`n"
		Out .= gIndent "}"
		gaList_PseudoArr.Push({name: P[1], newname: "a" P[1]})
		gaList_PseudoArr.Push({strict: true, name: P[1], newname: "a" P[1] ".Length"})
	}
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_RegExMatch(p)
{
	global gaList_MatchObj, gaList_PseudoArr
	; V1: FoundPos := RegExMatch(Haystack, NeedleRegEx , OutputVar, StartingPos := 1)
	; V2: FoundPos := RegExMatch(Haystack, NeedleRegEx , &OutputVar, StartingPos := 1)

	if (p[3] != "") {
		OrigPattern := P[2]
		OutputVar := p[3]

		CaptNames := [], pos := 1
		while pos := RegExMatch(OrigPattern, "(?<!\\)(?:\\\\)*\(\?<(\w+)>", &Match, pos)
			pos += Match.Len, CaptNames.Push(Match[1])

		Out := ""
		if (RegExMatch(OrigPattern, '^"([^"(])*O([^"(])*\)(.*)$', &Match)) {
			; Mode 3 (match object)
			; v1OutputVar.Value(1) -> v2OutputVar[1]
			; The v1 methods Count and Mark are properties in v2.
			P[2] := ( Match[1] || Match[2] ? '"' Match[1] Match[2] ")" : '"' ) . Match[3] ; Remove the "O" from the options
			gaList_MatchObj.Push(OutputVar)
		} else if (RegExMatch(OrigPattern, '^"([^"(])*P([^"(])*\)(.*)$', &Match)) {
			; Mode 2 (position-and-length)
			; v1OutputVar		-> v2OutputVar.Len
			; v1OutputVarPos1	-> v2OutputVar.Pos[1]
			; v1OutputVarLen1	-> v2OutputVar.Len[1]
			P[2] := ( Match[1] || Match[2] ? '"' Match[1] Match[2] ")" : '"' ) . Match[3] ; Remove the "P" from the options
			gaList_PseudoArr.Push({name: OutputVar "Len", newname: OutputVar '.Len'})
			gaList_PseudoArr.Push({name: OutputVar "Pos", newname: OutputVar '.Pos'})
			gaList_PseudoArr.Push({strict: true, name: OutputVar, newname: OutputVar ".Len"})
			for CaptName in CaptNames {
				gaList_PseudoArr.Push({strict: true, name: OutputVar "Len" CaptName, newname: OutputVar '.Len["' CaptName '"]'})
				gaList_PseudoArr.Push({strict: true, name: OutputVar "Pos" CaptName, newname: OutputVar '.Pos["' CaptName '"]'})
			}
		} else if (RegExMatch(OrigPattern, 'i)^"[a-z``]*\)')) ; Explicit options.
			|| RegExMatch(OrigPattern, 'i)^"[^"]*[^a-z``]') { ; Explicit no options.
			; Mode 1 (Default)
			; v1OutputVar	-> v2OutputVar[0]
			; v1OutputVar1	-> v2OutputVar[1]
			; 2024-06-22 AMB - Added regex property to be used in ConvertPseudoArray()
			gaList_PseudoArr.Push({regex: true, name: OutputVar})
			gaList_PseudoArr.Push({regex: true, strict: true, name: OutputVar, newname: OutputVar "[0]"})
			for CaptName in CaptNames
				gaList_PseudoArr.Push({strict: true, name: OutputVar CaptName, newname: OutputVar '["' CaptName '"]'})
		} else {
			; Unknown mode. Unclear options, possibly variables obscuring the parameter.
			; Treat as default mode?... The unhandled options O and P will make v2 throw anyway.
			; 2024-06-22 AMB - Added regex property to be used in ConvertPseudoArray()
			gaList_PseudoArr.Push({regex: true, name: OutputVar})
			gaList_PseudoArr.Push({regex: true, strict: true, name: OutputVar, newname: OutputVar "[0]"})
		}
		Out .= Format("RegExMatch({1}, {2}, &{3}, {4})", p*)
	} else {
		Out := Format("RegExMatch({1}, {2}, , {4})", p*)
	}
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
