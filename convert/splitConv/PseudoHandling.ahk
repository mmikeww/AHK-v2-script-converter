
; 2025-12-24 AMB, MOVED Dynamic Conversion Funcs to AhkLangConv.ahk

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
;################################################################################
;//	Example array123 => array[123]
;//	Example array%A_index% => array[A_index]
;//	Special cases in RegExMatch		=> {OutVar: OutVar[0],		OutVar0: ""				}
;//	Special cases in StringSplit	=> {OutVar: "",				OutVar0: OutVar.Length	}
;//	Special cases in WinGet(List) => {OutVar: OutVar.Length,	OutVar0: ""				}
;// Converts PseudoArray to Array
ConvertPseudoArray(ScriptStringInput, PseudoArrayName) {
; 2025-10-12 AMB, UPDATED to fix issue #118-1

	; The caller does a fast InStr before calling.
	; Summary of suffix variations depending on sources:
	;	- StringSplit		=> OutVar:Blank		; OutVar0:Length; OutVarN:Items;
	;	- WinGet-List		=> OutVar:Length	; OutVar0:Blank;	OutVarN:Items;
	;	- RegExMatch-Mode1	=> OutVar:Text		; OutVar0:Blank;	OutVarN:Items;
	;	- RegExMatch-Mode2	=> OutVar:Length	; OutVar0:Blank;	OutVarN:Blank; OutVarPosN:Item-pos; OutVarLenN:Item-len;
	;	- RegExMatch-Mode3	=> OutVar:Object	; OutVar0:Blank;	OutVarN:Blank;

	; 2025-10-12 AMB - add custom masking to avoid updating var within RegexMatch()
	sessID := clsMask.NewSession()						; create isolated masking session (might not be necessary, but doesn't hurt)
	Mask_T(&ScriptStringInput, 'C&S',,sessID)			; hide comments/strings within isolated session
	nRM := '(?i)REGEXMATCH' . gPtn_PrnthBlk				; create custom needle for RegexMatch() calls
	Mask_T(&ScriptStringInput, 'RXM', nRM)				; hide RegexMatch calls (custom masking)

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
	Mask_R(&ScriptStringInput, 'RXM')					; restore all RegexMatch() calls
	Mask_R(&ScriptStringInput, 'C&S',,sessID)			; restore comments/strings from isolated session only
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