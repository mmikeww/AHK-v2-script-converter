;################################################################################
															  splitLine(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; separates non-convert portion of line from portion to be converted
; returns non-convert portion in 'lineOpen' (hotkey declaration, opening brace, Try\Else, etc)
; returns rest of line (that requires conversion) in 'lineStr'

	noKywdCommas(&lineStr)				; first remove trailing commas from keywords (including Switch)
	lineOpen := ''						; will become non-convert portion of line
	firstTwo := subStr(lineStr, 1, 2)

	; if line is not a hotstring, but is single-line hotkey with cmd, separate hotkey from cmd temporarily...
	;	so the cmd can be processed alone. The hotkey will be re-combined with cmd after it is converted.
;	nHotKey	:= gPtn_HOTKEY . '(.*)' ;((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
	; TODO - need to update needle for more accurate targetting
	nHotKey	:= '((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
	if ((firstTwo	!= '::') && RegExMatch(LineStr, nHotKey, &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with switch, separate any value following it temporarily....
	;	so the cmd can be processed alone. The opening part will be re-combined with cmd after it is converted.
	; any trailing comma for switch statement should have already been removed via noKywdCommas()
	nSwitch := 'i)^(\h*\bswitch\h*+)(.*+)'
	if (RegExMatch(LineStr, nSwitch, &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with case or default, separate any command following it temporarily...
	;	so the cmd can be processed alone. The opening part will be re-combined with cmd after it is converted.
	nCaseDefault := 'i)^(\h*(?:case .*?|default):(?!=)\h*+)(.*+)$'
	if (RegExMatch(LineStr, nCaseDefault, &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with Try or Else, separate any command that may follow them temporarily...
	;	so the cmd can be processed alone. The try/else will be re-combined with cmd after it is converted.
	nTryElse := 'i)^(\h*+}?\h*+(?:Try|Else)\h*[\h{]\h*+)(.*+)$'
	if (RegExMatch(LineStr, nTryElse, &m) && m[2]) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with {, separate any command following it temporarily...
	;	so the cmd can be processed alone. The { will be re-combined with cmd after it is converted.
	if (RegExMatch(LineStr, '^(\h*+{\h*+)(.*+)$', &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with } (but not else), separate any command following it temporarily...
	;	so the cmd can be processed alone. The } will be re-combined with cmd after it is converted.
	if (RegExMatch(LineStr, 'i)^(\h*}(?!\h*else|\h*\n)\h*)(.*+)$', &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	return lineOpen
}
;################################################################################
														   noKywdCommas(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; removes trailing commas from some AHK keywords/commands

	nFlow	:= 'i)^(\h*)(else|for|if|loop|return|switch|while)(?:\h*,\h*|\h+)(.*)$'
	lineStr	:= RegExReplace(lineStr, nFlow, '$1$2 $3')
	return		; lineStr by reference
}
;################################################################################
												  v1v2_fixTernaryBlanks(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; fixes ternary IF - when value for 'true' or 'false' is blank/missing
; added support for multi-line
; [var ?  : "1"] => [var ? "" : "1"]
; [var ? "1" : ] => [var ? "1" : ""]
; TODO - Add unit tests for this... see below

;return

	Mask_T(&lineStr, 'STR')
		; for blank/missing 'true' value, single or multi-line
		lineStr := RegExReplace(lineStr, '(?im)^(.*?\s*+)\?(\h*+)(\s*+):(\h*+)(.+)$', '$1?$2""$3:$4$5')
		; for blank/missing 'false' value, SINGLE-line
		lineStr := RegExReplace(lineStr, '(?im)^(.*?\h\?.*?:\h*)(\)|$)', '$1 ""$2')
		; for blank/missing 'false' value, MULTI-line
		lineStr := RegExReplace(lineStr, '(?im)^(.*?\h*+)(\v+\h*+\?[^\v]+\v++)(\h*+:)(\h*+)(\){1,}|$)', '$1$2$3$4""$5')
	Mask_R(&lineStr, 'STR')

	return		; lineStr by reference
}
;################################################################################
v1v2_CorrectNEQ(&lineStr) {
; 2025-06-12 AMB, UPDATED - some var and funcCall names
; Converts <> to !=

   if (!InStr(lineStr, '<>'))
      return

   Mask_T(&lineStr, 'STR')   ; protect "<>" within strings
   lineStr := StrReplace(lineStr, '<>', '!=')
   Mask_R(&lineStr, 'STR')
   return   ; lineStr by reference
}
;################################################################################
																	   isHex(val)
;################################################################################
{
; 2025-06-30 AMB, ADDED - determines whether val is a hex val

	val := trim(val)
	return ((IsNumber(val)) && (val ~= '(?i)^0x[0-9a-f]+$'))
}