/* DESCRIPTION AND CHANGE LOG
	2024-04-08 - ADDED by andymbody to support code-block masking
		All regex needles were designed to support masking tags. Feel free to contact me on AHK forum (direct message), if I can assist with edits
		Supports masking of the following (so far):
			* Block-comments, line-comments
			* Same-line quoted-strings for v1 or v2 (" or ')
			* V1 legacy (non-expression) multi-line string-blocks (assignment or continuation)
			* V1/V2 expression multi-line string-blocks (assignment or continuation)
			* Nested classes and functions, with relationship support
			* Nested If blocks (partial - in progress)
			* v1 label blocks (partial - in progress)
			* hotkeys, hotstrings
			will add more support for other code-blocks, AHK funcs, etc as needed
	2024-06-02 - UPDATED support for V1/V2 (non-V1legacy) same-line strings
	2024-06-17 - UPDATED quoted-string needle
	2024-06-26 - UPDATE support for V1/V2 (non-V1legacy) same-line strings
	2024-06-30 - ADDED (partial) support for v1 legacy multi-line strings
	2024-07-01 - ADDED fix for Issue #74
	2024-07-07 - ADDED support for masking V1/V2 (non-V1legacy) multi-line string-blocks; removal of block/line comments & string-blocks
				 UPDATED needles for line-comment, classes/funcs
	2024-08-06 - ADDED (partial) support for If-blocks, v1 label blocks, hotkeys, hotstrings
	2025-06-12 - UPDATED, Major edit to fix #333 [improper masking], bug fixes, needle updates, enhancement, and general code refactor

	TODO
		Better support for comment/string masking to avoid conflicts between them
		Finish support for Continuation sections
		Add support of other types of blocks/commands, etc.
		Add interctive component to prompt user for decisions?
		Refactor for separate support for v1.0 -> v1.1, and v1.1 -> v2
		Better support for labels - False positive - 'Default:' within switch block (need to mask switch blocks first)

		GENERAL TODO -
		2025-10-05 TODO - FIX OnExit - MISSING 2ND PARAM AND "RETURN 1" BEING PLACE AFTER EXITAPP
			SEE "DRAWLINE 123548C5" AHK FILE FOR EXAMPLE
		Fix	- gosub when it references hotkey-label rather than normal label. SEE "DRAWLINE 123548C5" (F1)
		Fix	- Labels named RELOAD - See TextEditor.ahk for example
		Fix	- Issue 377 - Var1 := % var2, Global var1 := % var2 (remove percent)
*/

;################################################################################
; 2025-06-22 - UPDATED most of these needles
; global needles that can be used from anywhere within project

global	  gTagChar		:= chr(0x2605) ; '★'															; unique char to ensure tags are unique
		, gTagPfx		:= '#TAG' . gTagChar															; common tag-prefix
		, gTagTrl		:= gTagChar . '#'																; common tag-trailer
		, gCBPH			:= gTagChar . 'CB_Placeholder' . gTagChar										; 2025-10-05 - Callback Placeholder
		, gMXPH			:= gTagChar . 'MX_Placeholder' . gTagChar										; 2025-10-05 - MaxIndex placeholder
		, gMNPH			:= gTagChar . 'MN_Placeholder' . gTagChar										; 2025-10-05 - MinIndex placeholder
		, gChop			:= ';[' . gTagChar . 'CHOP' . gTagChar . ']`r`n'								; 2025-10-05 - CHOP for marking sections in LabelAndFunc.ahk
		, gPauseChar	:= chr(0x27FC)	; ⟼															; 2025-10-05 - char for flowStr - Pause, then continue (has code)
		, gJumpChar		:= chr(0x27F9)	; ⟹															; 2025-10-05 - char for flowStr - Pass thru (has no code)
		, gExitChar		:= chr(0x2716)	; ✖															; 2025-10-05 - char for flowStr - exit cmd

		, gnLineComment	:= '(?<=^|\s)(?<!``);[^\v]*+'													; UPDATED - line comment (allows lead ws to be consumed already)
		, gnCmd_Comment	:= '^(?<ln>(?:[^;\s]++|(?<=``);|\h(?!\h+;))+)?(?<lc>(?:^|\h+);.*)$'				; 2025-10-05 - separates command side from first comment occurence
		, gPtn_LC		:= '(?m)' . gnLineComment														; UPDATED - line comments found on any line
		, gPtn_BC		:= '(?m)^\h*(/\*((?>[^*/]+|\*[^/]|/[^*])*)(?>(?-2)(?-1))*(?:\*/|\Z))'			; block comments
		, gPtn_KVO		:= '\{([^:,}\v]++:[^:,}]++)(,(?1))*+\}'											; UPDATED - {key1:val1,key2:val2} obects
		, gPtn_PrnthBlk	:= '(?<FcParth>\((?<FcParams>(?>[^()]++|(?-2))*)\))'		; very general		; nested parentheses block, single or multi-line
		, gPtn_SqrBkts	:= '(?<SqrBkts>\[(?<SqrParams>(?>[^][]++|(?-2))*)\])'		; very general		; nested parentheses block, single or multi-line
		, gPtn_PrnthML	:= '\(\R(?>[^\v\))]+|(?<!\n)\)|\R)*?\R\h*\)'				; very general		; nested parentheses block, MULTI-LINE ONLY
		. gPtn_CSectM1	:= buildPtn_CSM1()																; ADDED - line, plus cont sect 'method 1'
		, gPtn_CSectM2	:= buildPtn_CSM2()											; general			; ADDED - line, plus cont sect 'method 2', plus trailer
		, gPtn_FuncCall := '(?im)(?<FcName>[_a-z](?|\w++|\.(?=\w))*+)' . gPtn_PrnthBlk					; UPDATED - function call (supports ml and nested parentheses)
		, gPtn_Blk_FUNC	:= buildPtn_FUNC()																; function block (supports nesting)
		, gPtn_Blk_CLS	:= buildPtn_CLS()																; class block (supports nesting)
		, gPtn_V1L_MLSV	:= buildPtn_V1LegMLSV()															; UPDATED - v1 legacy (non-expr) multi-line string assignment
		, gPtn_Blk_LBLD	:= buildPtn_Label().NT															; UPDATED - Label declaration only
		, gPtn_Blk_LBLP	:= buildPtn_Label().WT															; UPDATED - label declaration plus possible comment
		, gPtn_Blk_LBL	:= buildPtn_Label().FB															; UPDATED - label block with braces
		, gPth_Blk_MLP	:= buildPtn_MLBlock().ParBlk													; ADDED	  - Multi-line Parentheses block
		, gPtn_HOTSTR	:= '^\h*+:(?<Opts>[^:\v]++)*+:(?<Trig>[^:\v]++)::'			; single line only	; UPDATED - hotstrings
		, gPtn_HS_LWS	:= '^\s*+:(?<Opts>[^:\v]++)*+:(?<Trig>[^:\v]++)::'			; single line only	; UPDATED - hotstrings (supports leading blank lines)
		, gPtn_HOTKEY	:= buildPtn_Hotkey().noLWS									; single line only	; UPDATED - hotkeys
		, gPtn_HK_LWS	:= buildPtn_Hotkey().LWS									; single line only	; UPDATED - hotkeys (supports leading blank lines)
		, gPtn_QS_1L	:= buildPtn_QStr()																; UPDATED - DQ or SQ quoted-string, 1l (UPDATED 2025-06-12)
		, gPtn_DQ_1L	:= buildPtn_QS_DQ()																; UPDATED - DQ-string, 1l (ADDED 2025-06-12)
		, gPtn_SQ_1L	:= buildPtn_QS_SQ()																; UPDATED - SQ-string, 1l (ADDED 2025-06-12)
		, gPtn_QS_MLPth	:= buildPtn_MLQSPth()															; UPDATED - quoted-string, ml (within parentheses)
		, gPtn_QS_ML	:= '(?<line1>:=\h*)\K"(([^"\v]++)\R)(?:\h*+[.|&,](?-2)*+)(?-1)++"'				; UPDATED - quoted-string, ml cont sect (not within parentheses)
		, gPtnVarAssign	:= '(?i)(\h*[_a-z](?|\w++|\.(?=\w))*+\h*+)'	; also supports obj.property		; 2025-07-03 AMB, ADDED		- Variable/Object assignment
		, gPtn_Blk_IF	:= buildPtn_IF().fullIF															; 2025-10-05 AMB, UPDATED	- IF block
		, gPtn_Blk_SW	:= buildPtn_Switch()															; 2025-10-05 AMB, UPDATED	- Switch block
		, gPtn_BLK_WH	:= buildPtn_While()																; 2025-10-05 AMB, ADDED		- While block
		, gPtn_Blk_LP	:= buildPtn_Loop()																; 2025-10-05 AMB, ADDED		- Loop block
		, gPtn_Blk_TRY	:= buildPtn_Try()																; 2025-10-05 AMB, ADDED		- Try block
		, gPtn_Blk_FOR	:= buildPtn_For()																; 2025-10-05 AMB, ADDED		- For block
		, gPtn_HotIf	:= '(?im)^\h*\K#HOTIF.*'														; 2025-10-05 AMB, ADDED		- HotIf
		, gHotKeyList	:= ''
		, gHotStrList	:= ''
		, gMLContList	:= []

;################################################################################
															   getTagType(srcStr)
;################################################################################
{
	tag := hasTag(srcStr)
	return ((tag) ? RegExReplace(tag, gTagPfx '([^_]*).+', '$1') : '')
}
;################################################################################
											  hasTag(srcStr := '', tagType := '')
;################################################################################
{
; 2025-06-12 AMB, ADDED
; Purpose: To determine whether srcStr has...
;	A. a very specific tag		(tagType := exact tag to search for)
;		if srcStr is specified, this will only return a positive result if tag is found within srcStr
;		leave srcStr blank to guarantee a return of orig sub-string from maskList, (even if tag is not found in srcStr)
;	B. a specific tag type		(tagtype := string identifier for a tag category)
;	C. any mask tag in general	(tagType := leave empty)

	; make sure tagType is a valid tag

	; A: find very specific mask-tag - return orig sub-string if found in maplist, false otherwise
	; (note: if srcStr is specified (not blank), will only return orig sub-string if tag is ALSO found in srcStr)
	;	leave srcStr blank to return orig sub-String regardless
	validTag	:= '(?i)' uniqueTag('\w+')
	if ((tagType ~= validTag) && clsMask.HasTag[tagType]) {							; if tag found in masklist...
		oCode	:= clsMask.GetOrig[tagType]											; ... get orig sub-string
		; if srcStr specified...
		;	... only return orig sub-string when tag is found in srcStr
		; if srcStr NOT specified, return orig sub-string in any case
		retVal	:= (srcStr) ? ((srcStr ~= tagType) ? oCode : false) : oCode
		return	retVal
	}

	; setup for B: or C:
	tagType		:= (tagType) ? (RegExReplace(tagType, '_$') . '_') : tagType		; ensure its last char is underscore
	nTagType	:= '(?i)' uniqueTag(tagType '\w+')									; build tagType needle

	; B: find specific type of mask-tag
	; C: find any mask-tag in general
	; return first matching tag found, false otherwise
	retval		:= (srcStr) ? (RegExMatch(srcStr, nTagType, &mTag) ? mTag[] : false) : false
	return		retVal
;	return !!(srcStr ~= tagType)		; T or F
}
;################################################################################
															 uniqueTag(uniqueStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED - returns unique tag based on passed unique-string
;	see top of this file for global var declaration
;	global	  gTagChar	:= chr(0x2605) ; '★'
;			, gTagPfx	:= '#TAG' gTagChar
;			, gTagTrl	:= gTagChar '#'

	return gTagPfx . uniqueStr . gTagTrl
}
;################################################################################
				 Mask_T(&code, targ, option:=unset, sessID:=unset, convert:=true)
;################################################################################
{
/*
 2025-06-22 AMB, ADDED as central hub for tagging code (rather than dedicated funcs)
	Replaces targetted SUBSTRINGS, within passed code, with UNIQUE TAGS
 the multiple targ 'case' strings below are for convenience...
	they can be reduced to a single exclusive string if desired...
	(I can't always remember which string should be used, so convering more than one option)
	TODO - might just set exclusive strings and a popup in Default when 'targ' is unknown
2025-10-05 AMB, UPDATED

 CODE param		- source-code/haystack that will be searched (for target sub-string type)
					2025-07-06 - CANNOT BE A TRULY GLOABAL VAR - will result in errors during recursion calls (see notes)
 TARG param		- UNIQUE term/str/key that identifies the switch-case below.
					the cases below will route the Mask_T() request to target the appropriate UNIQUE TYPE of sub-string
					add a custom (UNIQUE) case or term as desired below (and matching UNIQUE cases for Mask_R() below)
					if TARG is not found in case-list below, it will be considered a one-time (custom) target TERM
					the TERM provided in TARG param will be used to create a UNIQUE TAG, so use a UNIQUE TERM here.
 OPTION param	- means different things for different targets - see comments for details
					if TARG is custom (not covered in case-list below), use option as param for custom regex needle
					TODO - provide a list of what the option param does for each targ type
 SESSID param	- identifies the exclusive masking session that should be used during restore process
					Use clsMask.NewSession() prior to calling Mask_T() to create a sessID for this param
						that sessID will be passed along the chain with your masking request
					Use this same sessID with Mask_R() when restoring tags to their orignal sub-string
						only tags that are associated with the sessID will be restored (rather than global restore)
					If sessID is not specified, the restore will be global (all masks of TARG will be restored within CODE)
 NOTES:
	many of the case below have recursive calls back to this function...
	these recursive calls are for pre-masking requirements.
	These pre-masks hide other substrings temporarily so they do not interfere with the main request
	these additional steps are done automatically so the caller does not need to worry about coding these steps manually
	in other words... a single 'main-request' performs all the steps required 'behind the scenes'
	2025-07-06 AMB, NOTE:
		Potential issue using global vars (reference) for CODE param. This issue does not occur with the Converter project.
		Symptoms:
			Calling this using a variable with global scope (byref) will cause errors with recursive calls.
			The error: "'code' param has not been assigned a value".
		Solution:
			Must call from a FUNCTION that uses a local var, either thru a 'real' var that has been passed to that function,
				or a local var within that function. In other words, the var cannot have just exclusive global scope (I think).

*/

	switch targ,false	; case-insensitive
	{
		;################################################################################
		case	'C&S':										; COMMENTS AND STRINGS...
				Mask_T(&code,	 'BC',	 ,sessID?)			; 	recursion call - mask block comments
				Mask_T(&code,	 'LC',	 ,sessID?)			; 	recursion call - mask line  comments
				Mask_T(&code,	 'QS',	 ,sessID?)			; 	recursion call - mask quoted-strings (1line)
				if (IsSet(option) && (option & 1))			; default = DONT mask, 1 = mask
					Mask_T(&code, 'MLQS',,sessID?)			; 	recursion call - mask quoted-strings (ML)
		;################################################################################
		case	'BC':										; BLOCK COMMENTS
				clsMask.MaskAll(&code, 'BC'
					, gPtn_BC, sessID?)
		;################################################################################
		case	'LC':										; LINE COMMENTS
				clsMask.MaskAll(&code, 'LC'
					, gPtn_LC, sessID?)
		;################################################################################
		case	'HK','HOTKEY':								; HOT KEYS (declaration)
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				if (!IsSet(option) || (option & 1)) {		; premask by default, or if bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings				(INCLUDE MLQS)
					Mask_T(&code,	'V1MLS',0,sessID?)		; 	recursion call - mask legacy ML strings				(do not premask or restore)
					Mask_T(&code,	'MLPB',	0,sessID?)		; 	recursion call - mask multi-line parentheses blocks	(do not premask or restore)
				}
				nGblHK := '(?im)' gPtn_HOTKEY				; support searching script globally
				clsMask.MaskAll(&code,'HK'					; mask hotkeys
					, nGblHK, sessID?)
				if (!IsSet(option) || (option & 2)) {		; restore by default, or if bit 2 is set
					Mask_R(&code,	'MLPB',	,sessID?)		; 	restore multi-line parentheses blocks
					Mask_R(&code,	'V1MLS',,sessID?)		; 	restore legacy ML strings
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'HS','HOTSTR':								; HOT STRINGS (declaration)
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				if (!IsSet(option) || (option & 1)) {		; premask by default, or if bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings				(INCLUDE MLQS)
					Mask_T(&code,	'V1MLS',0,sessID?)		; 	recursion call - mask legacy ML strings				(do not premask or restore)
					Mask_T(&code,	'MLPB',	0,sessID?)		; 	recursion call - mask multi-line parentheses blocks	(do not premask or restore)
				}
				nGblHS := '(?im)' gPtn_HOTSTR				; support searching script globally
				clsMask.MaskAll(&code, 'HS'					; mask hotstrings
					, nGblHS, sessID?)
				if (!IsSet(option) || (option & 2)) {		; restore by default, or if bit 2 is set
					Mask_R(&code,	'MLPB',	,sessID?)		; 	restore multi-line parentheses blocks
					Mask_R(&code,	'V1MLS',,sessID?)		; 	restore legacy ML strings
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'LBL','LABELS':								; LABELS (declaration)
				if (!(code~='(?m)^[\h{}]*\S+?:(?=\h|$)')) {	; make sure there is a possible label within code
					return									; label should not be within code
				}
				; lots of things can interfere with label detection
				; mask potential false positives
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				if (!IsSet(option) || (option & 1)) {		; premask by default, or if bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings				(INCLUDE MLQS)
					Mask_T(&code,	'V1MLS',0,sessID?)		; 	recursion call - mask legacy ML strings				(do not premask or restore)
					Mask_T(&code,	'MLPB',	0,sessID?)		; 	recursion call - mask multi-line parentheses blocks (do not premask or restore)
					Mask_T(&code,	'HK',	0,sessID?)		; 	recursion call - mask hotkey declarations			(do not premask or restore)
					Mask_T(&code,	'HS',	0,sessID?)		; 	recursion call - mask hotstring declarations		(do not premask or restore)
					Mask_T(&code,	'KV',	0,sessID?)		; 	recursion call - mask key/vals						(do not premask or restore)
					Mask_T(&code,	'SW',	2,sessID?)		; 	recursion call - mask switch blocks					(do not premask or restore)
				}
;				clsMask.MaskAll(&code, 'LBLBLK'				; mask label blocks (that have braces)
;					, gPtn_Blk_LBL, sessID?)					; currently already supports (?im)
				clsMask.MaskAll(&code, 'LBL'				; mask label declaration only
					, gPtn_Blk_LBLP, sessID?)				; currently already supports (?im)
				if (!IsSet(option) || (option & 2)) {		; restore by default, or if bit 2 is set
					Mask_R(&code,	'SW',	,sessID?)		; 	restore switch blocks
					Mask_R(&code,	'KV',	,sessID?)		; 	restore key/vals
					Mask_R(&code,	'HS',	,sessID?)		; 	restore hotstring declarations
					Mask_R(&code,	'HK',	,sessID?)		; 	restore hotkey declarations
					Mask_R(&code,	'MLPB',	,sessID?)		; 	restore multi-line parentheses blocks
					Mask_R(&code,	'V1MLS',,sessID?)		; 	restore legacy ML strings
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'MLPB':										; MULTI-LINE PARENTHESES BLOCKS
				; premask/restore - OFF BY DEFAULT
				; set option to (3) to do both of these
				if (IsSet(option) && (option & 1)) {		; premask only when bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings				(INCLUDE MLQS)
				}
				clsMask.MaskAll(&code, 'MLPB'				; mask multi-line parentheses blocks
					, gPth_Blk_MLP, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'KV','KVO','KVP','KEYVAL':					; KEY/VAL pair/objects
				; premask/restore - OFF BY DEFAULT
				; set option to (3) to do both of these
				if (IsSet(option) && (option & 1)) {		; premask only when bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings				(INCLUDE MLQS)
				}
				clsMask.MaskAll(&code, 'KVO'				; mask key/val pairs/objects
					, gPtn_KVO, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'ARRSQ':									; Array literal with square brackets
				; premask/restore - OFF BY DEFAULT
				; set option to (3) to do both of these
				if (IsSet(option) && (option & 1)) {		; premask only when bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings				(INCLUDE MLQS)
				}
				clsMask.MaskAll(&code, 'ARRSQ'				; mask array literal list
					, gPtn_SqrBkts, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'V1MLS','V1LEGMLS':							; V1 LEGACY (non-expression) MULTI-LINE STRING
				; premask/restore - OFF BY DEFAULT
				; set option to (3) to do both of these
				if (IsSet(option) && (option & 1)) {		; premask only when bit 1 is set
					Mask_T(&code,	'C&S',	1,sessID?)		; 	recursion call - mask comments/strings (INCLUDE MLQS)
				}
				clsMask.MaskAll(&code, 'V1LEGMLS'			; mask v1 legacy ML strings
					, gPtn_V1L_MLSV, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code,	'C&S',	,sessID?)		; 	restore comments/strings
				}
		;################################################################################
		case	'DQ','DQSTR':								; QUOTED-STRINGS (1line, "" only)
				clsMask.MaskAll(&code, 'DQ'
					, gPtn_DQ_1L, sessID?)
		;################################################################################
		case	'SQ','SQSTR':								; QUOTED-STRINGS (1line, '' only)
				clsMask.MaskAll(&code, 'SQ'
					, gPtn_SQ_1L, sessID?)
		;################################################################################
		case	'QS','QSTR':								; QUOTED-STRINGS (1line, "" and/or '')
				clsMask.MaskAll(&code, 'QS'
					, gPtn_QS_1L, sessID?)
		;################################################################################
		case	'MLQS','MLSTR':								; QUOTED-STRINGS (multi-line)
				clsMask.MaskAll(&code, 'MLQS'
					, gPtn_QS_MLPth, sessID?)
		;################################################################################
		case	'STR','STRINGS':							; STRINGS (1line and ML)
				Mask_T(&code,	 'QS',	,sessID?)			; 	recursion call - mask quoted-strings (1line)
				Mask_T(&code,	 'MLQS',,sessID?)			; 	recursion call - mask quoted-strings (ML)
		;################################################################################
		case	'CS','CSECT':								; CONTINUATION SECTIONS (ANY)
				; 2025-06-22 - DONT MERGE THIS IDEA YET
				;Mask_T(&code,	'CS1',	,sessID?)			; 	recursion call - mask 'method 1' Cont Sects
				Mask_T(&code, 	'CS2',	,sessID?)			; 	recursion call - mask 'method 2' Cont Sects
		;################################################################################
		case	'CS1','CSECT1':								; CONTINUATION SECTIONS (METHOD 1)
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				; lots of premasks are done in next step
				Mask_T(&code,	'LBL',	1,sessID?)			; 	recursion call - mask label declarations (premask, but do not restore)
				clsMask.MaskAll(&code,	'MLCSECTM1'			; 	mask all METHOD 1 continuation sections
					, gPtn_CSectM1, sessID?)
				Mask_T(&code,	'LBL',	2,sessID?)			; 	recursion call - THIS IS ACTUALLY DOING RESTORE OF PREMASKS
				Mask_R(&code,	'LBL',	,sessID?)			; 	restore label declarations (restore by default)
		;################################################################################
		case	'CS2','CSECT2':								; CONTINUATION SECTIONS (METHOD 2)
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				Mask_T(&code,	'C&S',	,sessID?)			; 	recursion call - mask comments/strings (NOT ML strings!)
				clsMask.MaskAll(&code,	'MLCSECTM2'			; 	mask all METHOD 2 continuation sections
					, gPtn_CSectM2, sessID?)
				Mask_R(&code,	'C&S',	,sessID?)			; 	restore comments/strings
		;################################################################################
		case	'FC','FCALL':								; FUNCTION CALLS
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				Mask_T(&code,	'STR',	,sessID?)			; 	recursion call - mask strings
				clsMask.MaskAll(&code, 'FC'					; mask function calls
					, gPtn_FuncCall, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code, 'STR',,sessID?)			;	restore all strings [FROM TEMP SESSION]
				}
		;################################################################################
		case	'FUNC':										; FUNCTIONS
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				; premask/restore - OFF BY DEFAULT
				; set option to (3) to do both of these
				if (IsSet(option) && (option & 1)) {		; premask only when bit 1 is set
					Mask_T(&code,	'C&S',	 ,sessID?)		; 	recursion call - mask comments/strings
					Mask_T(&code,	'V1MLS',0,sessID?)		; 	recursion call - mask legacy ML strings
					Mask_T(&code,	'MLPB',	0,sessID?)		; 	recursion call - mask multi-line parentheses blocks
				}
				clsMask.MaskAll(&code, 'FUNC'				; mask functon blocks
					, gPtn_Blk_FUNC, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code, 'MLPB',	,sessID?)		; 	restore multi-line parentheses blocks
					Mask_R(&code, 'V1MLS',	,sessID?)		; 	restore legacy ML strings
					Mask_R(&code, 'C&S',	,sessID?)		;	restore comments/strings [FROM TEMP SESSION]
				}
		;################################################################################
		case	'CLS':
				if (!IsSet(sessID)) {
					sessID := clsMask.NewSession()			; create session as needed
				}
				; premask/restore - OFF BY DEFAULT
				; set option to (3) to do both of these
				if (IsSet(option) && (option & 1)) {		; premask only when bit 1 is set
					Mask_T(&code,	'C&S',	 ,sessID?)		; 	recursion call - mask comments/strings
					Mask_T(&code,	'V1MLS',0,sessID?)		; 	recursion call - mask legacy ML strings
					Mask_T(&code,	'MLPB',	0,sessID?)		; 	recursion call - mask multi-line parentheses blocks
				}
				clsMask.MaskAll(&code, 'CLS'				; mask class blocks
					, gPtn_Blk_CLS, sessID?)
				if (IsSet(option) && (option & 2)) {		; restore only when bit 2 is set
					Mask_R(&code, 'MLPB',	,sessID?)		; 	restore multi-line parentheses blocks
					Mask_R(&code, 'V1MLS',	,sessID?)		; 	restore legacy ML strings
					Mask_R(&code, 'C&S',	,sessID?)		;	restore comments/strings [FROM TEMP SESSION]
				}
		;################################################################################
		case	'BLOCKS', 'CLS&FUNC', 'FUNC&CLS':			; CLASSES and FUNCTION
				clsNodeMap.Mask_Blocks(&code,sessID?, convert)
		;################################################################################
		case	'IWTLFS':									; IWTLFS BLOCKS
				blkTypes:=['FOR','IF','LP','SW','TRY','WH']
				Loop blkTypes.Length {
					Mask_T(&code, blkTypes[A_Index], 0)
				}
		;################################################################################
		case	'FOR':										; FOR BLOCKS
				code := IWTLFS.Mask(code, 'FOR', option?)
		;################################################################################
		case	'IF':										; IF BLOCKS - v1 and v2
				IFs := ['IF','IFEXIST','IFNOTEXIST']
				Loop IFs.Length {
					IWTLFS.Mask(code, IFs[A_Index], option?)
				}
		;################################################################################
		case	'LP', 'LOOP':								; LOOP BLOCKS
				code := IWTLFS.Mask(code, 'LOOP', option?)
		;################################################################################
		case	'SW','SWITCH':								; SWITCH block
				code := IWTLFS.Mask(code, 'SWITCH', option?)
		;################################################################################
		case	'TRY':										; TRY BLOCKS
				code := IWTLFS.Mask(code, 'TRY', option?)
		;################################################################################
		case	'WH', 'WHILE':								; WHILE BLOCKS
				code := IWTLFS.Mask(code, 'WHILE', option?)
		;################################################################################
		case	'HIF', 'HOTIF':								; HOTIF
				clsMask.MaskAll(&code, 'HIF'
					, gPtn_HotIf, sessID?)
		;################################################################################
		default:
				; targ not found in case-list above...
				; ... so it may be a custom target for custom masking...
				; submit it as custom masking, not covered above
				; NOTE: needle should be provided thru OPTION param
				customNeedle := option						; making it clear
				clsMask.MaskAll(&code, targ					; mask custom
					, customNeedle, sessID?)
		;################################################################################
	}
	return
}
;################################################################################
				  Mask_R(&code, targ, delTag:=true, sessID:=unset, convert:=true)
;################################################################################
{
/*
 2025-06-22 AMB, ADDED as central hub for restoring substrings that were masked/tagged with Mask_T
	Replaces targetted TAGS, within passed code, with ORIG substrings.
	Also performs conversion (indirectly), of that restored substr, in most cases
 the multiple targ 'case' strings below are for convenience...
	they can be reduced to a single exclusive string if desired...
	(I can't always remember which string should be used, so convering more than one option. lol)
	TODO - might just set exclusive strings and a popup in Default when 'targ' is unknown
 delTag param - whether to remove the tag from the global (static) tag list or not
	removing the tag from the list is the default behavior...
	... but this should be disabled for a call, if the tag will be needed again later, for restoration
 convert param - whether to convert code as part of masking restore
	has no relevance with clsMask.RestoreAll() since this code is not converted
	but sub-class (custom) RestoreAll()'s use it (clsMLLineCont.RestoreAll at the moment)
2025-10-10 AMB, UPDATED to fix conflict between LC and STR restoration (chicken and egg delima)

 CODE param	- source-code/haystack that will be searched (for target TAGS), and ultimately converted (see CONVERT below)
					2025-07-06 - CANNOT BE A TRULY GLOABAL VAR - will result in errors during recursion calls (see notes)
 TARG param	- UNIQUE term/str/key that identifies the switch-case below.
					the cases below will route the Mask_R() request to target the appropriate UNIQUE TYPE of sub-string
					add a custom (UNIQUE) case or term as desired below (and matching UNIQUE cases for Mask_T() above)
					if TARG is not found in case-list below, it will be considered a one-time (custom) target TERM
					the TERM provided will be used to search for tags that have this UNIQUE TERM identifier
					if tags are found with that UNIQUE TERM, they will be restored to their orig sub-string
 DELTAG param	- whether to permanantly remove the tag from the global (static) tag list or not (after Mask_R() call)
					removing the tag from the list is the default behavior...
					... but this should be disabled for a call, if the tag will be needed again later, for restoration
						in other words... disable for temp calls, so other calls can have access to tags as well.
 SESSID param	- identifies the exclusive masking session that should be used during restore process
					Use clsMask.NewSession() prior to calling Mask_T() (above) to create a sessID for this param
						that sessID will be passed along the chain with your Mask_T() request (and can then be used with Mask_R())
					Use this same sessID with Mask_R() when restoring tags to their orignal sub-string
						only tags that are associated with the sessID will be restored (rather than global restore)
					If sessID is not specified, the restore will be global (all masks of TARG will be restored within CODE)
 CONVERT param	- Only used for CUSTOM-Restores - flag to tell a CUSTOM-restore whether to convert CODE (param) as part of the current Mask_R() call
					Conversion is usually enabled by default (for CUSTOM-Restores only)...
						... in that case... Mask_R() will return the CODE after being converted...
							... but, if you wish to inspect the ORIGINAL CODE (non-converted)... set this flag to false/0
 NOTES:
	many of the case below have recursive calls back to this function...
	these recursive calls are for pre-masking requirements.
	These pre-masks hide other substrings temporarily so they do not interfere with the main request
	these additional steps are done automatically so the caller does not need to worry about coding these steps manually
	in other words... a single 'main-request' performs all the steps required 'behind the scenes'
	2025-07-06 AMB, NOTE:
		Potential issue using global vars (reference) for CODE param. This issue does not occur with the Converter project.
		Symptoms:
			Calling this using a variable with global scope (byref) will cause errors with recursive calls.
			The error: "'code' param has not been assigned a value".
		Solution:
			Must call from a FUNCTION that uses a local var, either thru a 'real' var that has been passed to that function,
				or a local var within that function. In other words, the var cannot have just exclusive global scope (I think).

*/

	switch targ,false	; case-insensitive
	{
		;################################################################################
		case	'C&S','S&C':								; COMMENTS AND STRINGS...
				; ORDER MATTERS - reverse order of Mask_T
				ntMLQS	:= gTagPfx . 'MLQS_', 	ntQS := gTagPfx . 'QS_'
				ntLC	:= gTagPfx . 'LC_', 	ntBC := gTagPfx . 'BC_'
				hasTags := ((code ~= ntMLQS) || (code ~= ntQS) || (code ~= ntLC) || (code ~= ntBC))
				pass := 0
				While(hasTags) {
					Mask_R(&code, 'MLQS',delTag, sessID?)	; 	recursion call - restore quoted-strings (ML)
					Mask_R(&code, 'QS',	 delTag, sessID?)	; 	recursion call - restore quoted-strings (1line)
					Mask_R(&code, 'LC',	 delTag, sessID?)	; 	recursion call - restore line  comments
					Mask_R(&code, 'BC',	 delTag, sessID?)	; 	recursion call - restore block comments
					hasTags := (((code ~= ntMLQS) || (code ~= ntQS) || (code ~= ntLC) || (code ~= ntBC)) && !IsSet(sessID))
				}
		;################################################################################
		case	'BC':										; BLOCK COMMENTS
				clsMask.RestoreAll(&code, 'BC'
					, delTag, sessID?)
		;################################################################################
		case	'LC':										; LINE COMMENTS
				clsMask.RestoreAll(&code, 'LC'
					, delTag, sessID?)
		;################################################################################
		case	'HK','HOTKEY':								; HOT KEYS (declaration)
				clsMask.RestoreAll(&code, 'HK'
					, delTag, sessID?)
		;################################################################################
		case	'HS','HOTSTR':								; HOT STRINGS (declaration)
				clsMask.RestoreAll(&code, 'HS'
					, delTag, sessID?)
		;################################################################################
		case	'LBL','LABELS':								; LABELS (declaration)
				clsMask.RestoreAll(&code, 'LBL'
					, delTag, sessID?)
				clsMask.RestoreAll(&code, 'LBLBLK'			; label blocks (has braces)
					, delTag, sessID?)
		;################################################################################
		case	'MLPB':										; MULTI-LINE PARENTHESES BLOCKS
				clsMask.RestoreAll(&code, 'MLPB'
					, delTag, sessID?)
		;################################################################################
		case	'KV','KVO','KVP','KEYVAL':					; KEY/VAL pair/objects
				clsMask.RestoreAll(&code, 'KVO'
					, delTag, sessID?)
		;################################################################################
		case	'ARRSQ':									; Array literal with sqaure brackets
				clsMask.RestoreAll(&code, 'ARRSQ'
					, delTag, sessID?)
		;################################################################################
		case	'V1MLS','V1LEGMLS':							; V1 LEGACY (non-expression) MULTI-LINE STRING
				clsMask.RestoreAll(&code, 'V1LEGMLS'
					, delTag, sessID?)
		;################################################################################
		case	'DQ','DQSTR':								; QUOTED-STRINGS (1line, "" only)
				clsMask.RestoreAll(&code, 'DQ'
					, delTag, sessID?)
		;################################################################################
		case	'SQ','SQSTR':								; QUOTED-STRINGS (1line, '' only)
				clsMask.RestoreAll(&code, 'SQ'
					, delTag, sessID?)
		;################################################################################
		case	'QS', 'QSTR':								; QUOTED-STRINGS (1line, "" and/or '')
				clsMask.RestoreAll(&code, 'QS'
					, delTag, sessID?)
		;################################################################################
		case	'MLQS','MLSTR':								; QUOTED-STRINGS (multi-line)
				clsMask.RestoreAll(&code, 'MLQS'
					, delTag, sessID?)
		;################################################################################
		case	'STR', 'STRINGS':							; STRINGS (1line and ML)
				; ORDER MATTERS - reverse order of Mask_T
				Mask_R(&code, 'MLQS',delTag, sessID?)		; 	recursion call - restore quoted-strings (ML)
				Mask_R(&code, 'QS',  delTag, sessID?)		; 	recursion call - restore quoted-strings (1line)
		;################################################################################
		case	'CS','CSECT':								; CONTINUATION SECTIONS (ANY)
				; reverse order of Mask_T
				Mask_R(&code, 'CS2', delTag, sessID?)		; 	recursion call - restore method 2 cont sects
;				Mask_R(&code, 'CS1', delTag, sessID?)		; 	recursion call - restore method 1 cont sects
		;################################################################################
		case	'CS1','CSECT1':								; CONTINUATION SECTIONS (METHOD 1)
				; Subclass providing custom restore
				clsMLLineCont.RestoreAll(&code, 'MLCSECTM1'
					, delTag, sessID?, convert)				; will convert as part of restore, unless convert is set to 0
		;################################################################################
		case	'CS2','CSECT2':								; CONTINUATION SECTIONS (METHOD 2)
				; Subclass providing custom restore
				clsMLLineCont.RestoreAll(&code, 'MLCSECTM2'
					, delTag, sessID?, convert)				; will convert as part of restore, unless convert is set to 0
		;################################################################################
		case	'FC','FCALL':								; FUNCTION CALLS
				clsMask.RestoreAll(&code, 'FC'
					, delTag, sessID?)
				Mask_R(&code, 'STR', delTag,sessID?)		;	recursion call - restore quoted strings
		;################################################################################
		case	'FUNC':										; FUNCTION BLOCKS
				clsMask.RestoreAll(&code, 'FUNC'
					, delTag, sessID?)
				clsNodeMap.RestoreAll(&code, 'BLKFUNC'		; 2025-10-27 AMB
					, delTag, sessID?, convert)
		;################################################################################
		case	'CLS':										; CLASS BLOCKS
				clsMask.RestoreAll(&code, 'CLS'
					, delTag, sessID?)
				clsNodeMap.RestoreAll(&code, 'BLKCLS'		; 2025-10-27 AMB
					, delTag, sessID?, convert)
		;################################################################################
		case	'BLOCKS', 'CLS&FUNC', 'FUNC&CLS':			; CLASS and FUNCTION BLOCKS
				clsNodeMap.RestoreAll(&code, 'BLKCLS'		; 2025-10-27 AMB
					, delTag, sessID?, convert)
				clsNodeMap.RestoreAll(&code, 'BLKFUNC'		; 2025-10-27 AMB
					, delTag, sessID?, convert)
				;clsNodeMap.Restore_Blocks(&code,convert)
		;################################################################################
		case	'IWTLFS':									; IWTLFS BLOCKS
				nFILSTW := '(?im)' UniqueTag('(?:FOR|IF|LOOP|SWITCH|TRY|WHILE)\w++')
				while(code ~= nFILSTW) {
					blkTypes:=['FOR','IF','LP','SW','TRY','WH']
					Loop blkTypes.Length {
						Mask_R(&code, blkTypes[-A_Index]	; reverse order
							, delTag, sessID?)
					}
				}
				code := RegExReplace(code, '(?i) ★TRY_CRLF_\d+★\r\n')
		;################################################################################
		case	'FOR':										; FOR BLOCKS
				clsMask.RestoreAll(&code, 'FOR'
					, delTag, sessID?)
		;################################################################################
		case	'IF':										; IF BLOCKS - v1 and v2
				IFs := ['IF','IFEXIST','IFNOTEXIST']
				Loop IFs.Length {
				clsMask.RestoreAll(&code, IFs[-A_Index]
					, delTag, sessID?)
				}
		;################################################################################
		case	'LP', 'LOOP':								; LOOP BLOCKS
				clsMask.RestoreAll(&code, 'LOOP'
					, delTag, sessID?)
		;################################################################################
		case	'SW','SWITCH':								; SWITCH block
				clsMask.RestoreAll(&code, 'SWITCH'
					, delTag, sessID?)
		;################################################################################
		case	'TRY':										; TRY BLOCKS
				clsMask.RestoreAll(&code, 'TRY'
					, delTag, sessID?)
;				code := RegExReplace(code, '(?i) ★TRY_CRLF_\d+★\r\n')
		;################################################################################
		case	'WH', 'WHILE':								; WHILE BLOCKS
				clsMask.RestoreAll(&code, 'WHILE'
					, delTag, sessID?)
		;################################################################################
		case	'HIF', 'HOTIF':								; HOTIF
				clsMask.RestoreAll(&code, 'HIF'
					, delTag, sessID?)
		;################################################################################
		default:
				; targ not found in case-list above...
				; ... so it may be a custom target...
				; submit is as custom restore, not covered above
				clsMask.RestoreAll(&code, targ				; restore custom
					, delTag, sessID?)
		;################################################################################
	}
	return
}
;################################################################################
															RemovePtn(code, targ)
;################################################################################
{
; 2025-06-22 AMB, ADDED as central hub for removing targ substrings
;	Removes target substrings from passed code
; 2025-10-05 AMB, UPDATED

	switch targ, false	; case-insensitive
	{
		;################################################################################
		case 'BC':
			return RegExReplace(code, gPtn_BC)				; remove block comments
		;################################################################################
		case 'LC':
			; Mask strings first to prevent interference
			sess := clsMask.NewSession()					; temp masking session
			Mask_T(&code, 'STR',, sess)						; mask strings, within isolated session
				code := separateComment(code, &comment:='')
			Mask_R(&code, 'STR',, sess)						; restore strings, within isolated session
			return code
		;################################################################################
		case 'C', 'COM', 'LC&BC', 'COMMENTS':
			code := RemovePtn(code, 'BC')					; remove block comments
			return	RemovePtn(code, 'LC')					; remove line  comments
		;################################################################################
		case 'V1LEGMLS':
			return RegExReplace(code, gPtn_V1L_MLSV)		; remove v1 legacy (non-expression) ML string assignments
		;################################################################################
		default:
			return RegExReplace(code, targ)
			;return RegExReplace(code, escRegexChars(targ))
			; TODO - provide a list of valid 'targ' strings
		;################################################################################
	}
	return
}
;################################################################################
Class IWTLFS
{
; 2025-10-05 AMB, ADDED
; IWTLFS - these letters are arranged this way for a reason, can you tell me why?
; Supports masking nested-blocks of FOR, IF, LOOP, SWITCH, TRY, WHILE
; Supports single/multi-line/intermixed blocks of mentioned types
; TODO - ADD SUPPORT FOR MASKING OF MULTIPLE TYPES WITH SINGLE CALL

	;############################################################################
	Static _needles	:= Map(	'FOR'			,gPtn_Blk_FOR									; full needles for each node type
						,	'IF'			,gPtn_Blk_IF
						,	'IFEXIST'		,gPtn_Blk_IF									; may add more legacy IF types later
						,	'IFNOTEXIST'	,gPtn_Blk_IF									; have tested these If's briefly
						,	'LOOP'			,gPtn_Blk_LP
						,	'SWITCH'		,gPtn_Blk_SW
						,	'TRY'			,gPtn_Blk_TRY
						,	'WHILE'			,gPtn_BLK_WH )

	Static _sessID	:= ''
	;############################################################################
	; PUBLIC - call this method with each masking type, individually. But...
	;	each pass will mask all supported types by default, from bottom to top...
	;	then, if option is other than 0, will restore non-targ types
	;############################################################################
	Static Mask(code, targ:='', option:=0)													; Public entry point this class
	{
		if (!code)																			; if code is empty...
			return ''																		; ... don't process further
		; next 3 steps must be performed in ANY/ALL cases
		this._preMask_T(&code)																; premask comments, strings, v1 ML strings
		this._isolateTry(&code)																; place Trys on their own line
		this._maskAllNodes(&code)															; mask FOR, IF, LOOP, SWITCH, TRY, WHILE
		; should non-targ nodes be restored (limiting masking to targ only)?
		if (option=0)	; non-targ restoration not important								; is usually set to 0
			return code																		; will usually return now (all types masked)
		else if (targ)	; set option to anything other than 0 to get here					; [NOTE: ._maskAllNodes MUST be performed in ANY/ALL cases]
			this._maskTargOnly(&code, targ)													; limit masking to targ ONLY (remove mask from others)
		return code
	}
	;############################################################################
	Static _preMask_T(&code)																; premask to avoid conflicts
	{
		; TDDO - ADD PREMASKING FOR PARENTHESES ML BLOCKS ?
		sessID		 := clsMask.NewSession()												; create masking session
		this._sessID := sessID																; save sessID for restore later
		Mask_T(&code, 'C&S'	 ,1,sessID)														; mask comments/strings
		Mask_T(&code, 'V1MLS',, sessID)														; mask v1 ML strings
	}
	;############################################################################
	Static _preMask_R(&code)
	{
		Mask_R(&code, 'C&S'	 ,,	this._sessID)												; restore comments and strings
		Mask_R(&code, 'V1MLS',,	this._sessID)												; restore v1 ML strings
	}
	;############################################################################
	Static _isolateTry(&code)																; place Try on it's own line
	{
		nTry	:= '(?im)^([\h{}]*+\bTRY\b)(.+)'											; target Try (full line)
		While(pos := RegexMatch(code,nTry, &m, pos??1)) {									; for each Try line
			line	:= m[]																	; full Try line
			decl	:= m[1]																	; Try declaration
			trail	:= m[2]																	; trailing portion after Try (open brace, LC, etc)
			tag		:= ' ' gTagChar 'TRY_CRLF_' A_Index gTagChar							; unique tag for each occurrence
			repl	:= decl tag '`r`n' trail												; replacement str
			code	:= RegExReplace(code, escRegexChars(line), repl,,1,pos)					; replace Try line with tag
			pos		+= StrLen(repl)															; prep for next search
		}
	}
	;############################################################################
	Static _getPositions(code)																; get positions of nodes, return in reverse order
	{
		; get position of these declarations
		nodeTypes := ['FOR'																	; declarations we are looking for
					,'IF'
					,'IFEXIST'
					,'IFNOTEXIST'
					,'LOOP','SWITCH','TRY','WHILE']
		posMap := Map()
		for idx, nType in nodeTypes {														; for each node type...
			pos		:= 1																	; must be reset with each iteraion
			nTrail	:= '\b.++'
			nLead	:= '(?im)^[\h{}]*+(?:TRY\b\h*+)?' . nType
			if (nType='LOOP'||nType='TRY') {
				nTrail := '\b.*+'
			}
			if (nType='TRY') {
				notOth	:= '(?!\h+(?:FOR|IF(?:(?:NOT)?EXIST)?|LOOP|SWITCH|WHILE))'
				nLead	:= '(?im)^[\h{}]*+\bTRY\b' . notOth
			}
			needle	:= nLead . nTrail														; [detect declaration lines]
			while(pos := RegExMatch(code, needle, &m, pos)) {								; for each occurence of node-type...
				posMap[pos]	:= nType														; ... record position and type of node
				pos			+= m.len														; prep for next search
			}
		}
		; flip/reverse order of nodes in list [flip bottom to top]
		posStr := ''
		for pos, nType in posMap {															; add each node to vert list
			posStr .= ((posStr='') ? '' : '`n') . (pos ':' nType)							; update vert list
		}
		return Sort(posStr,'NR')															; return pos list in reverse order
	}
	;############################################################################
	Static _maskAllNodes(&code)																; mask each node [from bottom to top]
	{
		revPos := this._getPositions(code)													; get node positions in reverse order
		Loop parse, revPos, '`n', '`r' {													; for each node in list...
			ss	 := StrSplit(A_LoopField, ':')
			pos	 := ss[1], nType := ss[2]													; ... extract block position and type (from list)
			nCur := this._needles[nType]													; needle for current node type
			if (RegExMatch(code, nCur, &m, pos)) {											; this should always succeed
				oStr	:= m[]																; record original code/substring for current node
				ercStr	:= escRegexChars(oStr)												; escape special regex chars for orig subStr
				uid		:= clsMask.GenUniqueID()											; unique ID (this is a must to avoid issues!)
				uStr	:= nType '_' uid '_P' pos '_L' m.Len								; unique str (must have unique ID !)
				tag		:= uniqueTag(uStr)													; build a unique tag for current node
				mObj	:= clsMask(oStr, tag, nType, nCur)									; create new clsMask object
				clsMask.AddMask(tag, mObj)													; add object to shared maplist (using unique tag as key)
				code	:= RegExReplace(code, ercStr, tag,,1,pos)							; replace orig subStr with a tag
			}
		}
	}
	;############################################################################
	Static _maskTargOnly(&code, targ)														; targ nodes will be masked, but other supported types will be restored
	{
		this._unMask(&code, targ)															; remove masks/tags from nodes that are NOT targeted
		; only targeted nodes are masked/tagged now
		; get full orig subStrs for these, then remask
		nTag := '(?i)' uniqueTag('([^_]+)_P(\d+)\w+')										; [detect tags]
		uniqStr := ''
		While(pos	:= RegexMatch(code, nTag, &mTag, pos??1)) {								; for each remaining tag found...
			tag		:= mTag[],  skipLen := 0
			nType	:= mTag[1], oPos := mTag[2]												; extract tag type and orig position
			if (clsMask.HasTag[tag]) {														; if this is not a targeted node, skip it
				oStr	:= clsMask.GetOrig[tag]												; get orig substr for current tag
				nTCRLF	:= '(?i) ★TRY_CRLF_\d+★\r\n'										; tags for Trys that were moved to their own line
				oStr	:= RegExReplace(oStr, nTCRLF)										; remove any TRY prefix tag that was added earlier
				um		:= this._unMask(&oStr, '')	; note: targ param is empty				; remove ALL masks of supported types, found within orig substr
				newLen	:= StrLen(oStr)														; actual length, without temp masking
				uniqStr	:= (uniqStr='')														; get new unique ID for new tag, if not already
						? (ntype '_' clsMask.GenUniqueID() '_')
						: uniqStr
				uStr	:= uniqStr . A_Index												; add counter value
				newTag	:= uniqueTag(uStr '_P' oPos '_L' newLen)							; now has accurate tag details
				pattern := this._needles[nType]												; get needle for targ node
				mObj	:= clsMask(oStr, newTag, nType, pattern)							; create new clsMask object
				clsMask.AddMask(newTag, mObj)												; add object to shared maplist (using unique tag as key)
				code	:= RegExReplace(code, tag, newTag)									; replace old/temp tag with accurate tag
				;code	:= RegExReplace(code, tag, oStr)									; this will restore orig substrs for testing purposes
				skipLen	:= InStr(oStr, nType)												; [will skip any leading ws when setting new search position]
			}
			pos += skipLen +1
		}
	}
	;############################################################################
	Static _unMask(&code, targ)	; when targ is empty, unmask ALL supported types			; removes masks from ALL supported types, EXCEPT targ (when specified)
	{
		nTag	:= '(?i)' uniqueTag('([^_]+)_P(\d+)\w+')									; [detect any tag, and extraction of position]
		nType	:= targ																		; target type will not be restored
		oStr	:= '', oPos := 0															; ini
		While(pos	:= RegexMatch(code, nTag, &mTag, pos??1)) {								; for each tag found...
			tag		:= mTag[]																; tag string
			nType	:= mTag[1], oPos := mTag[2]												; tag type and orig pos
			skipLen	:= 0																	; ini to minimal offset for next search
			if ((nType != targ) && (clsMask.HasTag[tag])) {									; if cur tag is not a target, and orig str is avail...
				oStr	:= clsMask.GetOrig[tag]												; get orig str for tag
				oStr	:= RegExReplace(oStr, '(?i) ★TRY_CRLF_\d+★\r\n')					; remove any TRY prefix tag that was added earlier
				skipLen	:= InStr(oStr, nType)												; next search will begin at min distance from last match
				code	:= RegExReplace(code, tag, oStr)									; replace tag with orig str
			}
			pos += skipLen +1
		}
		this._preMask_R(&code)																; restore comments, strings, v1 ML strings
		return ; {nType:nType,oStr:oStr,oPos:oPos}
	}
}
;################################################################################
class clsMask
{
; Class responsible for masking (tagging/restoring) code
; Blocks of code are passed to MaskAll(), where targetted pattern substrings will be replaced with unique tags...
;	... the passed code is accompanied with a regex needle that identifies the targeted substrings
;	... the extracted substrings are then stored, and replaced with a unique tags (hiding them from conversion routines)
; When restoration is needed, the tagged-code is sent to RestoreAll() where...
;	... (unique) tags will be replaced with original code, but...
;	... as part of the restoration process, the substrings are usually sent to a custom converter prior to restoration.
; This class should be able to handle just about any type of masking/tagging desired
;	It just needs a well formed regex needle to identify the taggeted subsrings, and conversion func if required
;	These needles can be as simple or complex as your talents allow
;	Contact one of the developers/contributers, if you would like assisitance with a custom needle

	;############################################################################
	codePtn		:= ''						; block regex needle
	maskType	:= ''						; block type label
	mTag		:= ''						; unique tag label
	origCode	:= ''						; original code that is being masked
	isExit		:= unset					; whether block is an exclusive exit path

	__new(code, mTag, maskType, pattern)
	{
		this.origCode	:= code
		this.mTag		:= mTag
		this.maskType	:= maskType
		this.codePtn	:= pattern
	}
	;############################################################################
	static masklist		:= map()			; holds all premask objects, origCode/tags
	static uniqueIdList	:= map()			; ensures tags have unique ID
	;static maxMasks	:= 16**4			; 65K - CAUSED BUG!! NOT ENOUGH FOR HEAVY TESTING
	static maxMasks		:= 16**6			; 16.7 million (must be enough for heavy testing!!!)
	static maskCountT	:= 0				; 2025-06-12 - to prevent endless-loop bug
	;############################################################################
	; PUBLIC - establishes new masking session using clsMask._session
	; this can be used to control which tags are accessed/restored/deleted
	Static NewSession() {
		uniqID	:= this.GenUniqueID()
		sessObj	:= this._session(uniqID)
		return	sessObj
	}
	;############################################################################
	; PUBLIC - adds mask to masklist (if it passes verification)
	Static AddMask(tag, maskObj) {
		; make sure mask object (as value) and legit formatted tag (as key)
		if (!Type(maskObj)='clsMask' || hasTag(tag)!=tag)
			return
		this.masklist[tag] := maskObj				; is legit - add to list
	}
	;############################################################################
	; PUBLIC property - read only
	; TODO - return orig substr instead of T/F?
	Static HasTag[tagID] {
		get => this.masklist.Has(tagID)				; does tag exist in mask list?
	}
	;############################################################################
	; PUBLIC property - read only
	; returns orig substr for passed tag (if available), 0 otherwise
	Static GetOrig[tag] {
		get => (this.masklist.Has(tag))
			? (this.masklist[tag].origCode)
			: (gTagChar 'TagNotFound' gTagChar)		; obvious flag for debugging
	}
	;############################################################################
	; PRIVATE - removes tag record from maskList map
	Static _deleteTag(tag) {						; tag := list key
		if (this.masklist.has(tag))
			this.maskList.Delete(tag)
	}
	;############################################################################
	; PUBLIC - generates a unique 6bit hex value
	; used for unique tag ids and session ids
	Static GenUniqueID(){
		while(true) {
			; make sure lockup (endless loop) does not occur (again)
			if (this.maskCountT >= this.maxMasks) {
				MsgBox('Fatal Error: Max number of masks (' this.maxMasks ') have been used.`nEnding program!')
				ExitApp
			}
			; generate random 6 bit hex value (string)
			rnd	:= Random(1, this.maxMasks), rHx := format('{:06}',Format('{:X}', rnd))	; 6 char hex string
			if (!this.uniqueIdList.has(rHx)) {	; make sure value is not already in use
				this.uniqueIdList[rHx] := true, this.maskCountT++
				break
			}
		}
		return rHx
	}
	;############################################################################
	; PUBLIC - searches for sub-pattern in code and masks/tags the occurences (sub-strings)
	; not for classes or functions - see clsNodeMap methods for those
	; param defaults set to empty to avoid errors when custom calls have missing args
	;	the following are required for any call: code, maskType, pattern
	;	sessObj is optional
	;############################################################################
	Static MaskAll(&code:='', maskType:='', pattern:='', sessObj:=unset)
	{
		; ensure required args have been provided by caller
		if (!code || !maskType || !pattern) {											; prevent issues with missing args
			return
		}
		; search for targ-pattern, replace matching substrs with tags, save original substr
		uniqStr	:= ''
		mMsg	:= ''	; DEBUG
		while (pos := RegExMatch(code, pattern, &m, pos??1))
		{
			; record match details
			mCode		:= m[], mLen := m.Len
			adjCode		:= RegExReplace(code, '★', '1')
			; setup unique tag id - only generate as needed
			maskType	:= RegExReplace(maskType, '_$',,,1) . '_'						; ensure its last char is underscore
			uniqStr		:= (uniqStr='')
						? (maskType clsMask.GenUniqueID() '_')
						: uniqStr
			; create tag, and store orig code using premask object
			mTag 	:= uniqueTag(uniqStr A_Index '_P' pos '_L' mLen)					; tag to be used for masking
			mObj	:= clsMask(mCode, mTag, maskType, pattern)							; create new clsMask object
			clsMask.AddMask(mTag, mObj)													; add object to shared maplist (using unique tag as key)
			; add tag to session if sessObj was provided by caller
			if (IsSet(sessObj) && Type(sessObj)='clsMask._session') {					; if caller provided a session id (session object)
				sessObj.AddTag(mTag)													; store tag in that session as well
			}
			; Replace original code with a unique tag
			code	:= RegExReplace(code, escRegexChars(mCode), mTag,,1,pos)			; supports position
			pos		+= StrLen(mTag)														; set position for next search
		}
	}

	;############################################################################
	; PUBLIC - finds tags within code and replaces the tags with original substr
	; No conversion is performed here by default...
	; OVERRIDE this method in sub-classes (for custom restores/conversions)
	; TODO - MAY IMPLEMENT FUNC-CALLBACK PARAM FOR CUSTOM CONVERSIONS/RESTORES...
	;	(RATHER THAN SUB-CLASS REQUIREMENT)
	; param defaults set to empty to avoid errors when custom calls have missing args
	;	the following are required for any call: code, maskType
	;	sessObj is optional
	;############################################################################
	Static RestoreAll(&code:='', maskType:='', deleteTag:=true, sessObj:=unset)
	{
		; ensure required args have been provided by caller
		if (!code || !maskType) {												; prevent issues with missing args
			return
		}
		; setup unique tag id
		maskType	:= RegExReplace(maskType, '_$',,,1) . '_'					; ensure its last  char is underscore
		nMTag		:= uniqueTag(maskType '\w+')								; needle to find a tag that has maskType identifier
		; search for targ-pattern, replace matching tags with orig substr
		while (pos	:= RegExMatch(code, nMTag, &m, pos??1))
		{
			mTag	:= m[]														; [working var for tag]
			; if sessObj was provided...
			;	... restore substrs for tags associated...
			;	... with that session only
			if (IsSet(sessObj) && Type(sessObj)='clsMask._session') {			; if caller provided a session id (session obj)...
				if (!sessObj.HasTag[mTag]) {									; ... if tag is not found in session list, ignore it
					pos += StrLen(mTag)											; prep for next search
					continue													; skip to next search
				}
			}
			; restore orig substr for current tag
			oCode	:= clsMask.GetOrig[mTag]									; get orig substr (for current tag) from tag list
			code	:= StrReplace(code, mTag, oCode)							; replace current (unique) tag with orig substr
			pos		+= StrLen(oCode)											; prep for next search
		}
	}
	;############################################################################
	; OVERRIDE in sub-classes (for custom conversions)
	Static _convertCode(&code)
	{
	}
	;############################################################################
	; PRIVATE
	class _session		; internal class
	{
	; 2025-06-22 AMB, ADDED - to support masking/access/restore of select set of tags (only)
	; Intented to be accessed/used excelusively by clsMask
	; This helps prevent restoring/deleting of tags that may still be in use by other routines
	; ... each session keeps its own list of tags that belong to that session only
	; these session tags are also listed in the static/shared clsMask.Masklist map

		_sessList	:= map()						; holds session tag ids
		_sessID		:= ''							; unique session id

		__new(sessID) {
			this._sessID := sessID
		}

		; PUBLIC property - read only
		HasTag[tagID] {
			get => this._sessList.Has(tagID)		; does tag exist in session list?
		}

		; PUBLIC method to add tag to session map
		AddTag(tagID) {
			this._sessList[tagID] := true
		}
	}
}
;################################################################################
class clsMLLineCont extends clsMask
{
; 2025-06-12 AMB, ADDED - WORK IN PROGRESS, may move to ContSection.ahk
; for multi-line continuation sections, including previous line and optional trailer params

;	;############################################################################
;	; 2025-06-12 AMB, ADDED for consistency
;	;	but is not used - clsMLLineCont utilizes internal call to parent class (clsMask) for Masking
;	; PUBLIC - searches for sub-pattern in code and masks/tags the occurences (sub-strings)
;	; OVERRIDES clsMask MaskAll method
;	static MaskAll(&code, maskType, pattern) {
;	}
	;############################################################################
	; PUBLIC - finds tags within code and replaces the tags with converted substr
	; OVERRIDES clsMask.RestoreAll() method for custom conversion
	; note: currently not forcing/verifying masktype (tags) as 'MLCSECTM2' here...
	;	since the assumption is... no code should pass thru here unless it has a 'MLCSECTM2' tag
	;	if this turns out to be a false assumption, will address it then
	; 	(don't want the converter code to be too specific, so it can be copy/pasted/used elsewhere)
	; param defaults set to empty to avoid errors with missing args (although, should not happen)
	;	the following are required for any call: code, maskType
	;	sessObj is optional
	;############################################################################
	static RestoreAll(&code:='', maskType:='', deleteTag:=true, sessObj:=unset, convert:=true)
	{
		; ensure required args have been provided by caller
		if (!code || !maskType) {											; prevent issues with missing args
			return
		}
		; setup unique tag id
		maskType	:= RegExReplace(maskType, '_$',,,1) . '_'				; ensure its last  char is underscore
		nMTag		:= uniqueTag(maskType '\w+')							; needle to find a tag that has maskType identifier
		; search for targ-pattern, replace matching tags with orig substr
		while (pos := RegExMatch(code, nMTag, &m)) {						; position is unnecessary
			mTag	:= m[]													; [working var for tag]
			; this is actually accessing clsMask.masklist
			oCode	:= clsMLLineCont.masklist[mTag].origCode				; get original substr (for current tag) from tag list
			; this masking is general in scope. Need to vet orig code...
			; send orig substr thru a filter which will...
			;	... redirect conversion to the appropiate routine
			if (convert) {
				clsMLLineCont._convertCode(&oCode)							; [THIS STEP IS THE REASON for the dedicated clsMLLineCont sub-class]
			}
			code	:= StrReplace(code, mTag, oCode)						; replace current tag with original (converted) substr
		}
	}
	;############################################################################
	; Overrides clsMask._convertCode() method for custom conversion
	Static _convertCode(&code)
	{
		code := CSect.FilterAndConvert(code)								; 2025-06-22 - redirected conversion (should be permanent)
	}
}
;################################################################################
class clsNodeMap	; 'block map' might be better term
{
; used for mapping and supporting details of code-blocks such as functions, classes, while, loop, if, etc
; supports relationships between nested blocks
; included to support tracking of local/global variables and modular-conversions

	;############################################################################
	name					:= ''		; name of block
	BlockCode				:= ''		; orig block code - used to determine whether code was converted
	ConvCode				:= ''		; converted code
	cType					:= ''		; CLS, FUNC, etc
	uid						:= ''		; unique ID for tag (2025-10-27)
	tagId					:= ''		; unique tag
	parentPos				:= -1		; -1 is root
	pos						:= -1		; block start position within code, ALSO use as unique key for MapList
	len						:= 0		; char length of entire block
	ParentList				:= ''		; list of parent ids (immediate parent will be listed first)
	ChildList				:= map()	; list of child nodes

	; acts as constructor for a node object
	__new(name, cType, blkCode, uid, pos, len)
	{
		this.name			:= name
		this.cType			:= cType
		this.blockCode		:= blkCode
		this.uid			:= uid		; 2025-10-27
		this.pos			:= pos
		this.len			:= len
	}
	;############################################################################
	; PRIVATE - returns the nested path depth of the node
	_depth() {
		StrReplace(this.PathVal, '\',,, &count)
		return count
	}
;	;############################################################################
;	; PRIVATE - custom sort for path depth
;	_depthSort(a1,a2,*)
;	{
;		RegExMatch(a1, '(\d+):(\d+):', &m1)
;		RegExMatch(a2, '(\d+):(\d+):', &m2)
;		return ((m2[2] > m1[2]) ? 1 : ((m2[2] < m1[2]) ? -1 : ((m2[1] > m1[1]) ? 1 : ((m2[1] < m1[1]) ? -1 : 0))))
;	}
	;############################################################################
	; PUBLIC - convenience - returns string list of ChildList map()
	GetChildren() {
		cList := ''
		for key, childNode in this.ChildList {
			cList .= ((cList='') ? '' : ';') . ('[' key ']' . childNode.name)
		}
		return cList
	}
	;############################################################################
	EndPos					=> this.pos + this.len
	ParentName				=> (this.parentPos > 0)	 ? clsNodeMap.mapList[this.parentPos].name : 'Root'
	Path					=> ((this.parentPos > 0) ? clsNodeMap.mapList[this.parentPos].Path : '') . ('\' this.name)
	PathVal					=> ((this.parentPos > 0) ? clsNodeMap.mapList[this.parentPos].PathVal : '') . ('\' this.pos)
	AddChild(id)			=> this.ChildList[id]	:= clsNodeMap.mapList[id]	; add node object
	hasChildren				=> this.ChildList.Count
	hasChanged				=> (this.ConvCode && (this.ConvCode = this.BlockCode))
	;############################################################################
	static mapList			:= map()
	static maskList			:= map()						; 2025-10-27 AMB, ADDED
;	static idIndex			:= 0
;	static nextIdx			=> ++clsNodeMap.IdIndex
;	static getNode(id)		=> clsNodeMap.mapList(id)
;	static getName(id)		=> clsNodeMap.mapList(id).name
	;############################################################################
	; PRIVATE - adds a node to maplist
	static _add(node) {
		this.mapList[node.pos] := node
	}
	;############################################################################
	; PUBLIC - provides details of all nodes in maplist
	; used for debugging, etc.
	static Report() {
		reportStr := ''
		for key, nm in this.MapList {
			reportStr	.= '`nname:`t[' nm.cType '] ' nm.name '`nstart:`t' nm.pos '`nend:`t' nm.EndPos '`nlen:`t' nm.len
						. '`nparent:`t' nm.parentName ' [' nm.parentPos ']`npath:`t' nm.path '`npathV:`t' nm.pathVal '`nDepth:`t' nm._depth()
						. '`nPList:`t' nm.parentList '`nChilds:`t' nm.GetChildren() '`n'
		}
		return reportStr
	}
	;############################################################################
	; PUBLIC - builds a position map of all classes and functions found in script
	;	also identifies relationship between nodes
	static BuildNodeMap(code)
	{
		this.Reset()							; each build requires a fresh MapList
		Mask_T(&code, 'C&S',1)					; mask comments/strings - might be redundant
		Mask_T(&code, 'V1MLS')					; mask v1 ML strings
		uid := clsMask.GenUniqueID()
		; map all classes - including nested ones, from top to bottom
		pos := 1
		while(pos := RegExMatch(code, gPtn_Blk_CLS, &m, pos)) {
			chunk := SubStr(code, 1, pos)
			this._add(this(m.cname, 'BLKCLS', m[], uid, pos, m.len))
			pos += m.len
		}
		; map all functions - including nested ones, from top to bottom
		pos := 1, curPos := pos
		while(pos := RegExMatch(code, gPtn_Blk_FUNC, &m, pos)) {
			if (m[]='') {
				pos++, curPos := pos
				continue	; bypass IF/WHILE/LOOP
			}
			this._add(this(m.fname, 'BLKFUNC', m[], uid, pos, m.len))
			curPos := pos, pos += m.len
		}
		; identify parents and children for each node in maplist
		this._setKin()
	}
	;############################################################################
	; PUBLIC - mask and convert classes and functions
	static MaskAndConvertNodes(&code, convert:=true)
	{
		; prep for tagging - get list of node positions
		nodeDepthStr := ''
		for key, node in this.mapList
			nodeDepthStr .= ((nodeDepthStr='') ? '' : '`n') . (key ':' node._depth() ':' node.name)

		; mask/tag each class and function, FROM BOTTOM TO TOP - REVERSE ORDER!
		reversedDepthStr := Sort(nodeDepthStr,'NR')
		Loop parse, reversedDepthStr, '`n', '`r'
		{
			; [pos] serves two purposes...
			;	1. starting char position of node [class,func,etc] within code body
			;	2. used as unique key for mapList[] (ensures map sort order is same as order found in code)
			pos		:= RegExReplace(A_LoopField, '^(\d+).+', '$1')	; extract pos/Key of current node
			node	:= this.mapList[number(pos)]

			; if node is a class
			if (node.cType='BLKCLS')
			{
				if ((RegExMatch(code, gPtn_Blk_CLS, &m, pos))=pos)				; node position is known and specific
				{
					mCopy := m[]												; is premasked code - copy to prep for v2 conversion
					Mask_R(&mCopy, 'V1MLS',0), Mask_R(&mCopy, 'C&S',0)			; restore comments/strings, v1 ML strings (should now be orig)
					node.ConvCode := (convert)	? _convertLines(mCopy)			; convert or not?
												: mCopy
					mLen		:= StrLen(node.ConvCode)
					uid			:= node.uid										; 2025-10-27 AMB, ensure tag has unique ID
					mTag		:= uniqueTag('BLKCLS_' uid '_P' pos '_L' mLen)	; tag, also used as key for maskList
					this.maskList[mTag] := node									; 2025-10-27 AMB, so FUNC/CLS masking is more flexible
					code := RegExReplace(code, escRegexChars(m[]), mTag,,1,pos)	; replace block of premasked-code with tag
				}
			}

			; if node is a function
			else if (node.cType='BLKFUNC')
			{
				if ((RegExMatch(code, gPtn_Blk_FUNC, &m, pos))=pos)				; node position is known and specific
				{
					mCopy := m[]												; is premasked code - copy to prep for v2 conversion
					Mask_R(&mCopy, 'V1MLS',0), Mask_R(&mCopy, 'C&S',0)			; restore comments/strings, v1 ML strings (should now be orig)
					node.ConvCode := (convert)	? _convertLines(mCopy)			; convert or not?
												: mCopy
					mLen		:= StrLen(node.ConvCode)
					uid			:= node.uid										; 2025-10-27 AMB, ensure tag has unique ID
					mTag		:= uniqueTag('BLKFUNC_' uid '_P' pos '_L' mLen)	; tag, also used as key for maskList
					this.maskList[mTag] := node									; 2025-10-27 AMB, so FUNC/CLS masking is more flexible
					code := RegExReplace(code, escRegexChars(m[]), mTag,,1,pos)	; replace block of premasked-code with tag
				}
			}
		}
	}
	;############################################################################
	; PUBLIC - replaces class/func code with tags (indirectly)
	; converts original code in the process, stores it to be retrieved by Restore_Blocks()
	static Mask_Blocks(&code, sessID?, convert:=true)
	{
		if (!IsSet(sessID)) {
			sessID := clsMask.NewSession()
		}
		Mask_T(&code, 'C&S',1,sessID)							; mask comments/strings - might be redundant
		Mask_T(&code, 'V1MLS',,sessID)							; mask v1 ML strings
			; mask classes and functions
			this.BuildNodeMap(code)								; prep for masking/conversion
			this.maskAndConvertNodes(&code,convert)				; FUNC/CLS will be added to masklist here
		Mask_R(&code, 'V1MLS',0,sessID)							; restore v1 ML strings
		Mask_R(&code, 'C&S',0,sessID)							; restore comments/strings
	}
	;############################################################################
	; PUBLIC - replaces class/func code with v2 converted version (converted in MaskAndConvertNodes)
	static Restore_Blocks(&code, convert:=true)
	{
	; 2025-10-27 AMB - begin using RestoreAll() instead

		for key, node in this.mapList {
			mTag		:= node.tagId
			repl		:= (convert)
						? node.convCode
						: node.BlockCode
			code		:= StrReplace(code, mTag, repl)			; would RegexReplace() have better performance?
			;code		:= RegExReplace(code, mTag, repl)		; 2025-06-12 CAUSES ISSUES WITH REGEX NEEDLES
		}
	}
	;############################################################################
	static RestoreAll(&code:='', maskType:='', deleteTag:=true, sessObj:=unset, convert:=true)
	{
	; 2025-10-27 AMB - Begin using this for restore, more flexible

		; ensure required args have been provided by caller
		if (!code || !maskType) {								; prevent issues with missing args
			return
		}
		; setup unique tag id
		maskType	:= RegExReplace(maskType, '_$',,,1) . '_'	; ensure its last  char is underscore
		nMTag		:= uniqueTag(maskType '\w+')				; needle to find a tag that has maskType identifier
		; search for targ-pattern, replace matching tags with orig substr
		while (pos := RegExMatch(code, nMTag, &m)) {			; position is unnecessary
			mTag		:= m[]									; [working var for tag]
			node		:= this.maskList[mTag]
			repl		:= (convert)							; convert or not?
						? node.convCode							; ... when converting
						: node.BlockCode						; ... when NOT converting
			code		:= StrReplace(code, mTag, repl)			; would RegexReplace() have better performance?
		}
	}
	;############################################################################
	; PRIVATE - identifies all parents/children for each node in nodelist
	static _setKin() {
		for key, node in this.mapList {
			node.ParentPos := this._findParents(node.name, node.pos, node.len)
		}
	}
	;############################################################################
	; PRIVATE - find all parents/children for passed block, return immediate parent
	static _findParents(name, pos, len)
	{
		cp := -1, parentList := map()
		; find parent via brute force (by comparing code positions)
		for key, node in this.mapList {
			if ((pos>node.pos) && ((pos+len)<node.EndPos)) {
				offset				:= pos-node.pos				; looking for lowest offset (closest parent)
				parentList[offset]	:= node.pos					; add current parent id to list
				node.AddChild(pos)								; add this node to the ChildList of parent
				cp := ((cp < 0 || offset < cp) ? offset : cp)	; identify immediate (closest) parent
			}
		}
		; if no parent found, root is the parent
		if (cp<0) {
			this.mapList[pos].parentList := 'r'					; add root as only parent
			return -1											; -1 indicates root as only parent
		}
		; has at least 1 parent, save parent list, return immediate parent (pos)
		pList := parentList[cp] . ''
		for idx, parent in parentList {
			if (!InStr(pList, parent))
				pList .= ';' parent
		}
		pList .= ';r'				; add root
		this.mapList[pos].parentList := pList
		return parentList[cp]		; pos is used as mapList [key]
	}
	;############################################################################
	; PUBLIC - clears maplist
	static Reset()
	{
		this.mapList := Map()
	}
}
;################################################################################
								 _getNodeNameList(code, nodeType, parentName:='')
;################################################################################
{
; 2024-07-07 AMB, ADDED
; intended to be used internally by this .ahk only
; TODO - MOVE TO clsNodeMap Class ?
; returns a comma-delim stringList of node names extracted from passed code
; nodeType can be 'FUNC' for function names or 'CLS' for class names
; parentName can be specified to return only names of children of that parent
;	use  1 or 'root' to return only top level nodes names
;	use -1 to return nodes that are not top level (only child-node names)

	parentName := (parentName=1) ? 'root' : parentName

	retList	 := ''
	nodeList := _getNodeList(code, nodeType)
	for idx, node in nodeList {
		if (!parentName) {
			retList .= node.name . ','
		}
		else if (parentName=-1 && node.ParentName!='root') {
			retList .= node.name . ','
		}
		else if (parentName && node.ParentName=parentName) {
			retList .= node.name . ','
		}
	}
	return retList
}
;################################################################################
													 _getNodeList(code, nodeType)
;################################################################################
{
; 2024-07-07 AMB, ADDED
; TODO - MOVE TO clsNodeMap Class ?
; returns a list of block nodes of requested type (FUNC, CLS, clsV1Leg_MLSV, etc)
; Those nodes contain the details of the particualr block
; 	additional details can then be extracted from those nodes

;	Mask_T(&code, 'C&S')							; mask comments/strings
	clsNodeMap.BuildNodeMap(code)					; build node map

	; go thru node list and extract function names
	nodeList := []
	for key, node in clsNodeMap.mapList {
		if (node.cType=nodeType) {
			nodeList.Push(node)
		}
	}
	return nodeList
}
;################################################################################
											  getClassNames(code, parentName:='')
;################################################################################
{
; 2024-07-07 AMB, ADDED
; returns a comma-delim stringList of CLASS NAMES extracted from passed code
; parentName can be specified to return only names of children of that parent
;	use  1 or 'root' to return only top level class names
;	use -1 to return class names that are not top level (only child-class names)

	return _getNodeNameList(code, 'BLKCLS', parentName)
}
;################################################################################
											   getFuncNames(code, parentName:='')
;################################################################################
{
; 2024-07-07 AMB, ADDED
; returns a comma-delim stringList of FUNCTION NAMES extracted from passed code
; parentName can be specified to return only names of children of that parent
;	use  1 or 'root' to return only top level functions
;	use -1 to return func names that are not top level (only child-func names)

	return _getNodeNameList(code, 'BLKFUNC', parentName)
}
;################################################################################
															escRegexChars(srcStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED, part of Fix #333
; escapes regex special chars so regex can treat them literally
; for use with RegexReplace to target replacements using position accuracy

	outStr			:= srcStr
	specialChars	:= '\.?*+|^$(){}[]<>'
	for idx, char in StrSplit(specialChars) {
		outStr := StrReplace(outStr, char, '\' char)	; add preceding \ to special chars
	}
	return outStr
}
;################################################################################
																literalRegex(str)
;################################################################################
{
; 2025-06-12 AMB, ADDED, part of Fix #333 (use as needed)
; TODO - CURRENTLY NOT USED - use escRegexChars() instead

	return '\Q' StrReplace(str, '\E', '\E\\E\Q') '\E'
}
;################################################################################
				   StrReplaceAt(haystack, needle, repl, cs:=0, pos:=1, limit:=-1)
;################################################################################
{
; 2025-06-12 AMB, ADDED, part of Fix #333 (use as needed)
; adds position support for StrReplace
; BUT... is extremely SLOW!! Use sparingly (use RegexReplace instead, if possible)
; TODO - CURRENTLY NOT USED

	lead		:= SubStr(haystack, 1, pos - 1)
	trail		:= SubStr(haystack, pos)
	newTrail	:= StrReplace(trail, needle, repl, cs,, limit)
	return		lead . newTrail
}
;################################################################################
															 isBraceBlock(srcStr)
;################################################################################
{
; 2025-10-05 AMB, ADDED
; returns brace-block details, if srcStr BEGINS with a brace-block
;	ALSO supports optional leading ML ws, tags, and comments (line or block comments)
;	ALSO returns trailing portion after brace-block
; returns false when brace-block is positioned anywhere else in srcStr
;	so, should not detect false positives

	cbn		:= commonBlockNeedles()
	nTCT	:= cbn.TCT								; detect leading ws, comments, tags
	nBBG	:= cbn.bbg								; detect brace-block
	nTrail	:= '(?s)(?<trail>.*)'					; portion after braceblock
	nBlk	:= '^' . nTCT . nBBG . nTrail '$'		; full needle
	if (Regexmatch(srcStr, nBlk, &m)) {
		bb		:= m.bb								; brace-block {...}
		bbc		:= m.guts							; block contents (excluding braces)
		TCT		:= m.TCT							; leading ws, comments, tags
		trail	:= m.trail							; trailing portion after brace-block
		return {  bb	:bb							; full brace-block, including braces
				, bbc	:bbc						; brace-block contents, excluding braces
				, TCT	:TCT						; leading ws, comments, tags
				, trail	:trail						; trailing portion after brace-block
				, nBlk	:nBlk }						; also includes needle itself
	}
	return false
}
;################################################################################
																  TrimWS(&srcStr)
;################################################################################
{
; 2025-10-05 AMB, ADDED
; Cleans lines of leading/trailing whitspace, removes empty lines

	srcStr := RegExReplace(srcStr, '(?m)^\h+')
	srcStr := RegExReplace(srcStr, '(?m)\h+$')
	srcStr := RegExReplace(srcStr, '(?m)(\R)\R+','$1')
	srcStr := RegExReplace(srcStr, '^\R+')
	srcStr := RegExReplace(srcStr, '\R+$')
	return
}
;################################################################################
																buildPtn_Sep1LC()
;################################################################################
{
; 2025-10-05 AMB, ADDED - breakdown of line/comment separation needle (for clarity)
; targets first occurrence of line comment, rather than the last
; allows separation of comment from command portion of line
; see separateComment() in sharedCode.ahk, for usage details

	notSCWS	:= '[^;\s]++'													; not semi-colon or whitespace
	eSC		:= '(?<=``);'													; supports escaped semi-colon
	hWS		:= '\h(?!\h+;)'													; horz ws that is not followed by comment/(semi-colon)
	nLine	:= '(?<ln>(?:' notSCWS '|' eSC '|' hWS ')+)?'					; relevant line portion (anything other than line comment)
	nCom	:= '(?<lc>(?:^|\h+);.*)'										; line comment portion (also supports full-line LC)
	pattern	:= '^' . nLine . nCom . '$'										; full needle that targets first line comment
	; '^(?<ln>(?:[^;\s]++|(?<=``);|\h(?!\h+;))+)?(?<lc>(?:^|\h+);.*)$'
	return pattern
}
;################################################################################
															  buildPtn_MLReturn()
;################################################################################
{
; 2025-10-05 AMB, ADDED - to support RETURN that spans multi-line

	return '(?:\bRETURN\b.*+(?:(?:\R+\h*+(?:[,?.]|:(?!:)|\|\||&&|AND\h|OR\h)[^\v]++)+)?)'
}
;################################################################################
																 buildPtn_QS_DQ()
;################################################################################
{
; 2025-06-12 AMB, ADDED
; Single-line, DOUBLE-QUOTED strings [V1 or V2]

	return '(?<!``)(?<!")"(?>""|``"|````|``|[^"``\v]*+)*+"'
}
;################################################################################
																 buildPtn_QS_SQ()
;################################################################################
{
; 2025-06-12 AMB, ADDED
; Single-line, SINGLE-QUOTED strings [V2] (avoids apostrophe trigger)

	return '(?<!``)\B`'(?>```'|````|``|[^`'``\v]*+)*+`'\B'
}
;################################################################################
																  buildPtn_QStr()
;################################################################################
{
; 2025-06-12 AMB, ADDED to fix #333 (improper string masking)
; supports single-line, single/double-quoted strings (AHK v1 or v2)
; DOES NOT support v1 legacy (non-expression) strings

	return 	'(?:' buildPtn_QS_SQ() '|' buildPtn_QS_DQ() ')'	; combine single and double quotes
}
;################################################################################
															   buildPtn_MLBlock()
;################################################################################
{
; 2025-06-12 AMB, ADDED to support general multi-line blocks
; NOTE: these needles are designed as VERY POSSESSIVE (for efficiency and avoid errors)
; 2025-06-22 AMB, UPDATED needles to include/exclude trailer

	opt 		:= '(?im)'																	; CALLER MUST ADD this needle option manually (ignore case, multi-line)
	TG			:= '(?<tag>\h*+#TAG★(?:LC|BC|QS)\w++★#)'									; mask tags (line/block comment or quoted-string ONLY!)
	neck		:= '(?<neck>(?:(?&tag)|\h*+\R)++)'											; any tags or CRLFs before opening parenthesis
	mlOpt1		:= '(?:(?:(?<TJ>[LR]TRIM[^\v\)]*+|JOIN[^\v\)]*+)'							; ML string options (optional)
	mlOpt2		:= '(?:(?:C(?:OM(?:MENTS?)?)?)?(?:\h(?&TJ))?' TG '*+)'						; ML string comment or tags (optional)
	mlOpts		:= '(?<mlOpts>(?<=^|\v)\h*+(?<!``)\(\h*+' mlOpt1 '|' mlOpt2 ')))\h*+'		; all options for definition/declaration line
	lines		:= '(?<lines>\R*+[^\v]++)+?'												; lines that follow open parenthesis (lazy - one at a time)
	cls			:= '(?<cls>\s*+(?<!``)\))'													; closing parenthesis
	guts		:= '(?<guts>' cls '|' lines ')'												; all lines, then close
	parBlk		:= '(?<ParBlk>' mlOpts '\R' guts '(?(-2)|(?&cls)))'							; full body from open to close parentheses
	fullBlk		:= '(?im)(?<FullBlk>' . neck . parBlk ')'									; full multi-line block, including general neck (NO Trailer)
	fullT		:= fullBlk . '(?<trail>.*+)'												; full multi-line block, adds/allows trailer
	define		:= '(?im)(^|\R)' mlOpts . '$'												; can be used as signature to identiy ML string block
	nextLine	:= '[^\v]*+\R?'																; used in MaskAll of ML_Parenth class - for custom masking
	closer		:= '^(\h*(?<!``)\))[^\v]*+'													; used in MaskAll of ML_Parenth class - for custom masking
	retObj		:=	{ nOpt:		opt
					, full:		fullBlk
					, fullT:	fullT
					, ParBlk:	ParBlk
					, define:	define
					, nextLine:	nextLine
					, closer:	closer }
	return		retObj
}
;################################################################################
																  buildPtn_CSM1()
;################################################################################
{
; 2025-06-22 AMB, ADDED to support masking of "METHOD 1" continuation sections
;		described here: https://www.autohotkey.com/docs/v1/Scripts.htm#continuation
; NOTE: these needles are designed as VERY POSSESSIVE (for efficiency and avoid errors)

	opt 		:= '(?im)'
	exclude		:= '(?:\b(?!#TAG\b|AND\b|OR\b)[^.:?|&\v])'							; chars and terms that are not allowed to begin line 1
	line1		:= '^\h*\K(?<line1>' . exclude . '.++\R)'							; should avoid false positives
	TG			:= '(?<tag>\h*+#TAG★(?:LC|BC|QS)\w++★#)'							; mask tags (line/block comment or quoted-string ONLY!)
	TGLN		:= '(?:' . TG . '\h*+\R++)*+'										; allows full tag lines in between continuation lines
	CSLine		:= '(?<CSLns>\h*+(?:[,?.]|:(?!:)|\|\||&&|AND\h|OR\h)[^\v]++)'		; continuation line (does not require ws after dot)
	CSBlk		:= '(?<CSBlk>(?:\R*' TGLN . CSLine . ')+)'							; full continuation section (following (declaration) line1)
	pattern		:= opt . line1 . CSBlk												; assemple output needle
	return		pattern
}
;################################################################################
																  buildPtn_CSM2()
;################################################################################
{
; 2025-06-22 AMB, ADDED to support masking of "METHOD 2" continuation sections
;	described here: https://www.autohotkey.com/docs/v1/Scripts.htm#continuation
; NOTE: needle is designed as VERY POSSESSIVE (for efficiency and avoid errors)

	return	'(?im)^\h*\K(?<line1>.++)' . buildPtn_MLBlock().FullT
}
;################################################################################
															 buildPtn_V1LegMLSV()
;################################################################################
{
; V1 Legacy multi-line string assignments (non-expression = ), NOT (:=)
; 2024-07-07 AMB, UPDATED for better performance...
;	updated comment needle to bypass escaped semicolon
; 2025-06-12 AMB, UPDATED to reflect actual purpose
;	This version will ONLY match assignments WITH VARIABLE NAME
;	ADDED support for block comments (thru buildPtn_MLBlock())
; 2025-07-03 AMB, UPDATED needle to support obj.property

	return	'(?im)(?<decl>(?<var>[_a-z](?|\w++|\.(?=\w))*+)\h*+``?=)' . buildPtn_MLBlock().FullT
}
;################################################################################
															   buildPtn_MLQSPth()
;################################################################################
{
; supports multi-line single/double-quoted strings (AHK v1 or v2)
; supports multi-line v1 legacy (non-assignment) string-blocks
; can also support multi-line v1 legacy assignment string-blocks (but not by default)
; 	see buildPtn_V1LegMLSV() for supporting v1 legacy multi-line string assignments (with variable declaration)
; 2025-06-12, UPDATED to fix #333 (improper string masking)

	; MUST ADD NEEDLE OPTIONS MANUALLY
	return	'(?:[:.]=|,|%)?\K\h*+("|\B`').*+' . buildPtn_MLBlock().full . '\h*+(?1)[^\v]*+'
}
;################################################################################
																 buildPtn_Label()
;################################################################################
{
; 2024-08-06 AMB, ADDED - Label (block - NOT YET)
; WORK IN PROGRESS - IS CURRENTLY ONLY LABEL DECLARATION AND COMMENT
;	DOES NOT (YET) INCLUDE LINES THAT FOLLOW LABEL DECLARATION

; TODO - FIX FALSE POSITIVE (line that begins with semicolon)
;comment:

	opt 	:= '(?im)'														; pattern options
	LC		:= '(?:' gnLineComment ')'										; line comment (allows lead ws to be consumed already)
	TG		:= '(?:' uniqueTag('(?:LC|BC)\w++') ')'							; comment tag
	CT1		:= '(?<CT>(?:\h*+(?>' LC '|' TG ')))'							; line-comment OR tag
	CT2		:= '(?:' . LC . '|' . TG . ')*+'								; optional line comment OR tag
	TCT		:= '(?>\s*+' . CT2 . ')*+'										; optional trailing comment or tag (MUST BE ATOMIC)
	declare	:= '^\h*+(?<decl>(?::{0,2}(?:[^:,``\s]++|``[;%])++:)++)'		; declaration
	brcBlk	:= '\s*+(?<brcBlk>\{(?<BBC>(?>[^{}]++|(?-2))*+)})'				; brcBlk - braces block, BBC - block contents (allows multi-line span)
	noTrl	:= '(?!\S)(?=\h*$)'												; no trailer
	trl		:= '(?<trail>' . CT1 . '|\h*+(?=\v|$))'							; line-comment, tag, or end of line
	noTrail	:= opt . declare . noTrl										; no trailer
	wTrail	:= opt . declare . trl											; see globals at top on this file
	fullBlk	:= opt . '(?<declare>' declare . TCT . ')' . brcBlk
	return	{FB:fullBlk,NT:noTrail,WT:wTrail}
}
;################################################################################
																buildPtn_HotKey()
;################################################################################
{
; 2024-08-06 AMB, ADDED - Hotkey declaration
; 2025-06-22 AMB, UPDATED

	opt 	:= '(?i)'														; pattern options
	k01		:= '(?:[$~*]*)'													; special commands
	k02		:= '(?:[<>]?[!^+#]*+)*'	; do not use possessive here			; modifiers - short
	k03		:= '(?:[a-z0-9](?!\w))'	; single char only						; alpha-numeric
	k04		:= "[.?)(\][}{$|+*^:\\'``-]"									; symbols 1 (regex special)
	k05		:= '(?:``;|[<>,"~!@#%&=_])'										; symbols 2
	k06		:= '(?:[lrm]?(?:alt|c(?:on)?tro?l|shift|win|button)(?:\h+up)?)'	; modifiers - long
	k07		:= 'numpad(?:\d|end|add|sub)'									; numpad special
	k08		:= 'wheel(?:up|down)'											; mouse
	k09		:= '(?:f|joy)\d++'												; func keys or joystick button
	k10		:= '(?:(?:appskey|bkspc|(?:back)?space|del|delete|'				; named keys
			   . 'end|enter|esc(?:ape)?|home|pgdn|pgup|pause|tab|'
			   . 'up|dn|down|left|right|(?:caps|scroll)lock)(?:\h+up)?)'
	k11		:= '(?:sc[a-f0-9]{3})'											; 2025-06-22 ADDED - scancodes
	repeat	:= '(?:\h++(?:&\h++)?(?-1))*'									; allow repeated keys
	hotKeys := k01 '(' k02 '(?:' k03 '|' k04 '|' k05 '|' k06
			. '|' k07 '|' k08 '|' k09 '|' k10 '|' k11 '))' . repeat . '::'
	HKLWS	:= opt . '^(\s*+' . hotKeys . ')'								; supports leading blank lines
	NOLWS	:= opt . '^(\h*+' . hotKeys . ')'								; DOES NOT support leading blank lines
	return	{noLWS:NOLWS,LWS:HKLWS}
}
;################################################################################
																   buildPtn_CLS()
;################################################################################
{
; CLASS-BLOCK pattern
; 2024-07-07 AMB, UPDATED comment needle to bypass escaped semicolon

	opt 		:= '(?im)'													; pattern options
	LC			:= '(?:' gnLineComment ')'									; line comment (allows lead ws to be consumed already)
	TG			:= '(?:' uniqueTag('\w++') ')'								; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*+'							; optional line comment OR tag
	TCT			:= '(?>\s*+' . CT . ')*+'									; optional trailing comment or tag (MUST BE ATOMIC)
	cName		:= '(?<cName>[_a-z]\w*+)'									; cName		- captures class name
	cExtends	:= '(?:(\h+EXTENDS\h+[_a-z]\w*+)?)'							; cExtends	- support extends keyword
	declare		:= '^\h*+\bCLASS\b\h++' . cName . cExtends					; declare	- class declaration
	brcBlk		:= '\s*+(?<brcBlk>\{(?<BBC>(?>[^{}]++|(?-2))*+)})'			; brcBlk	- braces block, BBC - block contents (allows multi-line span)
	pattern		:= opt . '(?<declare>' declare . TCT . ')' . brcBlk
	return		pattern
}
;################################################################################
																  buildPtn_FUNC()
;################################################################################
{
; FUNCTION-BLOCK pattern - supports class methods also
; 2024-07-07 AMB, UPDATED comment needle to bypass escaped semicolon

	opt 		:= '(?im)'													; pattern options
	LC			:= '(?:' gnLineComment ')'									; line comment (allows lead ws to be consumed already)
	TG			:= '(?:' uniqueTag('\w++') ')'								; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*+'							; optional line comment OR tag
	TCT			:= '(?>\s*+' . CT . ')*+'									; optional trailing comment or tag (MUST BE ATOMIC)
	exclude		:= '(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|'						; \K|		- added to prevent If/While/Loop from being captured
	fName		:= '(?<fName>[_a-z]\w*+)'									; fName		- captures function/method name
	fArgG		:= '(?<fArgG>\((?<Args>(?>[^()]++|(?-2))*+)\))'				; fArgG		- func params/args
	declare		:= fName . fArgG . '(?<TCT>' . TCT . '\s*+)'				; declare	- function declaration
	brcBlk		:= '(?<brcBlk>\{(?<BBC>(?>[^{}]++|(?-2))*+)}))'				; brcBlk	- braces block, BBC - block contents (allows multi-line span)
	pattern		:= opt . '^\h*+(?:' . exclude . declare . brcBlk
	return		pattern
}
;################################################################################
															 commonBlockNeedles()
;################################################################################
{
; 2025-10-05 AMB, ADDED - avoids repeating these common needles multiple times

	LC		:= gnLineComment												; line comment (allows lead ws to be consumed already)
	TG		:= uniqueTag('(?:LC|BC|QS)\w++')								; comment OR quoted string tags
	CT		:= '(?<CT>(?|' . LC . '|' . TG . '))'							; line comment OR LC/BC/QS tag
	CTM		:= CT . '*+'													; allowed to be optional or multiples
	TCT		:= '(?<TCT>(?>\s*+' . CTM . ')*+)'								; optional trailing line comment or tag (MUST BE ATOMIC/POSSESIVE)
	notTag	:= '(?:#(?!TAG))'												; # that is not beginning of tag
	brc		:= '\{(?!\h*\v)(?!\h*' . '(?&CT))'								; { that is not at end of line or before comment
	noHTBrc	:= '[^{;#\v]++'													; anything except for { or #
	cond	:= '(?<cond>(?:' noHTBrc '|' brc '|' notTag '|' '(?&CT)' ')++)'	; anything that does not include opening brace at end of line
	mcKywd	:= '(?<MCKW>(?|\s+(?|AND|OR|NOT)\h+|\s*(?|&&|\|\|)\h*))'		; kywds for multiple conditions	- supports multi-line
	mCond	:= '(?<MC>' . cond . '(?:' . mcKywd . '(?&cond))*+)'			; allows multiple conditions 	- supports multi-line
	bb		:= '(?<bb>\{(?>[^{}]++|(?-1))*+})'								; brace block					- supports multi-line
	bbg		:= '(?<bb>\{(?<guts>(?>[^{}]++|(?-2))*+)})'						; brace block (with guts)		- supports multi-line
	mlCont	:= '\s*[?:,.].+'												; allows multi-line continuatons without req brace blocks
	lnAny	:= '(?:[^\v]++)'												; to capture anything not already covered
	noBB	:= '(?<noBB>(?:' mlCont '|' lnAny ')*+)'						; no braces block - allow multi-line captures for certain situations
	lead	:= '(?im)^[\h{}]*+(?:TRY\b\h*+)?\K'								; leading portion of needle
	untl	:= '(?:(?&TCT)(?<untl>\s*+\bUNTIL\b.+))?'						; optional UNTIL - TODO - ADD SUPPORT FOR ML CONDITION
	retObj	:=	{ bb		:bb												; brace block
				, bbg		:bbg											; brace block (with guts)
				, cond		:cond											; condition
				, lead		:lead											; leading options, ws, try
				, mc		:mCond											; muliple conditions, supports multi-line
				, CT		:CT												; comment tag
				, noBB		:noBB											; NO brace block, supports multi-line in some cases
				, TCT		:TCT											; optional trailing line comment or LC tag, supports multi-line
				, untl		:untl }											; optional UNTIL - TODO - ADD SUPPORT FOR ML CONDITION
	return	retObj
}
;################################################################################
																	buildPtn_IF()
;################################################################################
{
; 2024-08-06 AMB, ADDED - IF block
; 2025-10-05 AMB, UPDATED

	cbn		:= commonBlockNeedles()											; get common needles
	bb2		:= '(?&bb)'														; [avoid repeating chars within needle]
	mc2		:= '(?&MC)'														; [avoid repeating chars within needle]
	noBB2	:= '(?&noBB)'													; [avoid repeating chars within needle]
	TCT		:= cbn.TCT														; optional trailing line comments or LC tags
	TCT2	:= '(?&TCT)'													; [avoid repeating chars within needle]

	prefix	:= '(?im)^[\h{}]*+'
	ifDecl	:= prefix . '\bIF(?:(?:NOT)?EXIST)?\b.+'
	efDecl	:= prefix . '\bELSE\h+IF\b.+'
	elDecl	:= prefix . '\bELSE\b(?!\h+IF).*'
	; IF portion
	ifStr	:= '[\h{}]*+\K(?<ifStr>\bIF(?:(?:NOT)?EXIST)?\b)'				; ifStr	- IF delaration
	ifArg	:= '(?<ifArg>(?:\h*+' . cbn.mc						. '))'		; ifArg	- all arguments (conditions and opt trail comments/tags)
	ifBlk	:= '(?<ifBlk>\s*+(?:' . cbn.bb . '|' . cbn.noBB 	. '))'		; ifBlk	- block (either brace block or single line)
	IFSect	:= ifStr . ifArg  . TCT  . ifBlk
	; ELSEIF portion
	efStr	:= '(?<efStr>\h*+\bELSE\h+IF\b)'								; efStr	- ELSEIF declaration
	efArg1	:= '(?<efArg>(?:\h*+' . cbn.mc						. '))'		; efArg	- all arguments (conditions and opt trail comments/tags)
	efBlk1	:= '(?<efBlk>\s*+(?:' . cbn.bb . '|' . cbn.noBB		. '))'		; efBlk	- block (either brace block or single line)
	efArg2	:= '(?<efArg>(?:\h*+' . mc2							. '))'		; efArg	- all arguments (conditions and opt trail comments/tags)
	efBlk2	:= '(?<efBlk>\s*+(?:' . bb2 .    '|' . noBB2		. '))'		; efBlk	- block (either brace block or single line)
	EFSect1	:= efStr . efArg1 . TCT  . efBlk1
	EFSect2	:= efStr . efArg2 . TCT2 . efBlk2
	; ELSE portion
	elStr	:= '(?<elStr>\h*+\bELSE\b(?!\h+IF))'							; elStr	- ELSE declaration
	elBlk1	:= '(?<elBlk>\s*+(?:' . cbn.bb . '|' . cbn.noBB		. '))'		; elBlk	- block (either brace block or single line)
	elBlk2	:= '(?<elBlk>\s*+(?:' . bb2    . '|' . noBB2		. '))'		; elBlk	- block (either brace block or single line)
	ELSect1	:= elStr .		    TCT  . elBlk1
	ELSect2	:= elStr .		    TCT2 . elBlk2

	fullIF	:= 	'(?im)^(?<fullIF>'	ifSect									; IF
			. 	'(?:'	TCT2 .		efSect2  . ')*+'						; ELSE IF	(optional/multiple)
			. 	'(?:'	TCT2 .		elSect2  . ')?)'						; ELSE		(optional)
	retObj	:=	{ fullIF	:fullIF
				, IFSect	:IFSect
				, EFSect	:EFSect1
				, ELSect	:ELSect1
				, IFDecl	:IFDecl
				, EFDecl	:EFDecl
				, ELDecl	:ELDecl }
	return	retObj
}
;################################################################################
																buildPtn_Switch()
;################################################################################
{
; 2025-07-01 AMB, ADDED - SWITCH-BLOCK
; 2025-10-05 AMB, UPDATED
/*
TODO - MAKE SURE FUNC CALLS ARE COVERED
	Switch MyFunc() {
	Case 1:MsgBox
	}
*/

	cbn		:= commonBlockNeedles()											; get common needles
	swSTr	:= '(?<swStr>\bSWITCH\b)'
	swArg	:= '(?<swArg>(?:\h*+' . cbn.mc							. '))?'
	swBlk	:= '\s*+(?<brcBlk>\{(?<BBC>(?>[^{}]++|(?-2))*+)})'
	pattern	:= '(?<fullSW>'		. swStr . swArg . cbn.TCT . swBlk 	. ')'
	return	cbn.lead . pattern
}
;################################################################################
																 buildPtn_While()
;################################################################################
{
; 2025-10-05 AMB, ADDED - WHILE-BLOCK
; TODO - ADD ELSE, UNTIL ?

	cbn		:= commonBlockNeedles()											; get common needles
	WStr	:= '(?<wStr>\bWHILE\b)'											; WStr	- WHILE declaration
	WArg	:= '(?<wArg>(?:\h*+' . cbn.mc							. '))'	; WArg	- all arguments (conditions and opt trail comments/tags)
	WBlk	:= '(?<WBlk>\s*+(?:' . cbn.bb .	'|'  . cbn.noBB			. '))'	; WBlk	- block (either brace block or single line)
	pattern	:= '(?<fullWH>'		 . WStr	  . WArg . cbn.TCT . WBlk	. ')'
	return	cbn.lead . pattern
}
;################################################################################
																  buildPtn_Loop()
;################################################################################
{
; 2025-10-05 AMB, ADDED - LOOP-BLOCK
; TODO - ADD ELSE

	cbn		:= commonBlockNeedles()											; get common needles
	LPStr	:= '(?<LPStr>\bLOOP\b)(?:\h*,)?'								; LPStr	- LOOP declaration
	LPArg	:= '(?<LPArg>(?:\h*+' . cbn.mc							. '))?'	; LPArg	- arguments (conditions and optional trailing comments/tags)
	LPBlk	:= '(?<LPBlk>\s*+(?:' . cbn.bb . '|' . cbn.noBB			. '))'	; LPBlk	- block (either brace block or single line)
	pattern	:= '(?<fullLP>' LPStr LPArg cbn.TCT LPBlk cbn.untl		. ')'
	return	cbn.lead . pattern
}
;################################################################################
																   buildPtn_For()
;################################################################################
{
; 2025-10-05 AMB, ADDED - FOR-BLOCK
; TODO - ADD ELSE

	cbn		:= commonBlockNeedles()											; get common needles
	fStr	:= '(?<fStr>\bFOR\b)'											; fStr	- FOR declaration
	fArg	:= '(?<fArg>(?:\h*+' . cbn.mc							. '))'	; fArg	- all arguments (conditions and opt trail comments/tags)
	fBlk	:= '(?<fBlk>\s*+(?:' . cbn.bb .	'|'  . cbn.noBB			. '))'	; fBlk	- block (either brace block or single line)
	pattern	:= '(?<fullFor>' fStr fArg cbn.TCT fBlk cbn.untl		. ')'
	return	cbn.lead . pattern
}
;################################################################################
																   buildPtn_Try()
;################################################################################
{
; 2025-10-05 AMB, ADDED - TRY-BLOCK
; TODO - ADD ELSE, FINALLY

	cbn		:= commonBlockNeedles()											; get common needles
	bb2		:= '(?&bb)'														; [avoid repeating chars within needle]
	mc2		:= '(?&MC)'														; [avoid repeating chars within needle]
	noBB2	:= '(?&noBB)'													; [avoid repeating chars within needle]
	TCT		:= cbn.TCT														; optional trailing line comments or LC tags
	TCT2	:= '(?&TCT)'													; [avoid repeating chars within needle]
	tStr	:= '(?<tStr>[\h{}]*+\K\bTRY\b)' 								; tStr	- TRY declaration
	tArg	:= '(?<tArg>(?:\h*+' . cbn.mc					. '))?'			; tArg	- arguments (conditions and optional trailing comments/tags)
	tBlk	:= '(?<tBlk>\s*+(?:' . cbn.bb . '|' . cbn.noBB	. '))'			; tBlk	- block (either brace block or single line)
	cStr	:= '(?<cStr>\h*+\bCATCH\b)			'							; cStr	- CATCH declaration
	cArg	:= '(?<cArg>(?:\h*+' . mc2	. '))?'								; cArg	- arguments (conditions and optional trailing comments/tags)
	cBlk	:= '(?<cBlk>\s*+(?:' . bb2 . '|' . noBB2 		. '))'			; cBlk	- block (either brace block or single line)
	pattern := '(?<fullTry>'	tStr . tArg . TCT  . tBlk					; TRY
;			.  '(?:'	TCT2 .	cStr . cArg . TCT2 . cBlk	. ')?)'			; CATCH	(optional)
			.  '(?:'	TCT2 .	cStr . cArg . TCT2 . cBlk	. ')*+)'		; CATCH	(optional/multiple)
	return	'(?im)^' . pattern
}
;################################################################################
; 2025-06-22 - MOVED here from ContSections.ahk (for now)...
;	... to avoid Include requirement when using MaskCode.ahk outside of converter (for testing)
;	... will eventually be moved back to original file
;################################################################################
															conv_ContParBlk(code)
;################################################################################
{
; 2025-06-12 AMB, ADDED - WORK IN PROGRESS
; 2025-06-22 AMB, UPDATED
; converts code within string continuation (parentheses) block
; TODO - WORK IN PROGRESS

	; verify code matches pattern
	if (!RegExMatch(code, '(?im)' . buildPtn_MLBlock().ParBlk, &mML)) {		; if code does not match CS pattern...
		return false														; ... return negatory!
	}

	body	:= code															; [parentheses block - working var]
	oBdy	:= body															; orig block code - will need this later

	; separate/tag leading and trailing ws
	nSep := '(?is)\((?<LWS>[^\v]*\R\s*)(?<guts>.*?)(?<TWS>\h*\R\h*)\)'		; [separation needle]
	RegExMatch(body, nSep, &mSep)											; fill vars - TODO - CHANGE TO VERIFICATION IF ?
	oLWS	:= mSep.LWS														; save orig leading  WS for restore later
	oTWS	:= mSep.TWS														; save orig trailing WS for restore later
	oGuts	:= mSep.guts													; save orig guts contents (excluding lead/trail ws)
	tLWS	:= gTagPfx 'LWS' gTagTrl										; create temp tag for leading  WS
	tTWS	:= gTagPfx 'TWS' gTagTrl										; create temp tag for trailing WS
	body	:= RegExReplace(body, '^\(' oLWS, '(' tLWS)						; replace orig lead  ws with a temp tag
	body	:= RegExReplace(body, oTWS '\)$', tTWS ')')						; replace orig trail ws with a temp tag

	; work on guts of body
	uGuts	:= oGuts														; updated/new guts - will be changed below
	Mask_R(&uGuts, 'str')													; remove masking from strings within guts only
	uGuts	:= '"' uGuts '"'												; add surounding double-quotes to guts (to prep for next step)
	v2_DQ_Literals(&uGuts)													; change "" to `" within guts only
	uGuts	:= RegExReplace(uGuts, '(?s)^"(.+)"$', '$1')					; remove surrounding DQs (to prep for next step)
	uGuts	:= RegExReplace(uGuts, '(?<!``)"', '``"')						; replace " (single) with `"
	uGuts	:= '"' uGuts '"'												; add surounding double-quotes to guts (again)

	; mask all %var% within guts
	nV1Var := '(?<!``)%([^%]+)(?<!``)%'										; [identifies %var%]
	clsMask.MaskAll(&uGuts, 'V1VAR', nV1Var)								; mask/hide all %var%s for now

	; add quotes before and after v1 vars
	nV1VarTag := gTagPfx 'V1VAR_\w+' gTagTrl								; [identifies V1Var tags]
	pos := 1
	While(pos := RegexMatch(uGuts, nV1VarTag, &mVarTag, pos)) {				; for each V1Var tag found...
		oTag	:= mVarTag[]												; tag found (orig)
		qTag	:= '" ' oTag ' "'											; ... add concat quotes around tag (INCLUDE CONCAT DOTS ALSO?)
		uGuts	:= RegExReplace(uGuts, oTag, qTag,,1,pos)					; replace orig tag with quoted tag
		pos		+= StrLen(qTag)												; prep for next loop iteration
	}
	uGuts		:= RegExReplace(uGuts, '^""\h*')							; cleanup any leading  "" (un-needed)
	uGuts		:= RegExReplace(uGuts, '\h*""$')							; cleanup any trailing "" (un-needed)
	body		:= StrReplace(body, oGuts, uGuts)							; replace orig guts with new guts

	; restore original %VAR%s, then replace each with VAR (remove %)
	clsMask.RestoreAll(&body, 'V1VAR')										; restore orig %VAR%s
	pos := 1
	While(pos := RegexMatch(body, nV1Var, &mVar, pos)) {					; for each %VAR% found...
		pVar	:= mVar[]													; %VAR%
		eVar	:= mVar[1]													; extracted var [gets VAR from %VAR%]
		body	:= RegExReplace(body, pVar, eVar,,1,pos)					; replace %VAR% with VAR
		pos		+= StrLen(eVar)												; prep for next loop iteration
	}

	; restore original lead/trail ws
	body := RegExReplace(body, tLWS, oLWS)									; replace leadWS  tag with orig ws code
	body := RegExReplace(body, tTWS, oTWS)									; replace trailWS tag with orig ws code

	; add leading empty lines to quoted text								; (simulate same output as v1)
	RegExReplace(oLWS, '\R',, &cCRLF)										; count CRLFs - will tells us how many (leading) empty lines
	if (cCRLF > 1) {	; first CRLF doesn't count							; if one or more empty lines...
		nBlk := '(?s)(\([^\v]*)(\R)(\s+)"(.+?)(\))'							; [separates block anatomy]
		body := RegExReplace(body, nBlk, '$1$2"$3$4$5')						; include those empty lines in quoted text (move leading DQ)
	}

	; if block is empty (it happens), add empty quotes
	if (RegExReplace(body, '\s') = '()') {									; if body is empty...
		body := RegExReplace(body, '(?s)(\(\R)', '$1""',,1)					; add empty string quotes below opening parenthesis
	}

	Mask_R(&body, 'C&S')													; restore comments/strings
	return body
}
;################################################################################
; 2025-06-22 MOVED here from ConvLoopFuncs.ahk (for now)...
;	... to avoid Include requirement when using MaskCode.ahk outside of converter (for testing)
;	... will eventually be moved back to original file
;################################################################################
														 v2_DQ_Literals(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, redesigned and moved to dedicated routine for cleaner convert loop
; Purpose: convert double-quote literals from "" (v1) to `" (v2) format
;	handles all of them, whether in function call params or not

	Mask_T(&lineStr, 'DQStr')									; tag any DQ strings, so they are easy to find

	; grab each string mask one at a time from lineStr
	nDQTag		:= gTagPfx 'DQ_\w+' gTagTrl						; [regex for DQ string tags]
	pos			:= 1
	While (pos	:= RegexMatch(lineStr, nDQTag, &mTag, pos)) {	; find each DQ string tag (masked-string)
		tagStr	:= mTag[]										; [temp var to handle tag and replacement]
		Mask_R(&tagStr,'DQStr')									; get orig string for current tag
		tagStr	:= SubStr(tagStr, 2, -1)						; strip outside DQ chars from each end of extracted string
		tagStr	:= RegExReplace(tagStr, '""', '``"')			; replace all remaining "" with `"
		tagStr	:= '"' tagStr '"'								; add DQ chars back to each end
		lineStr	:= StrReplace(lineStr, mTag[], tagStr)			; replace tag within lineStr with newly converted string
		pos		+= StrLen(tagStr)								; prep for next search
	}
	return
}