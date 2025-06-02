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
	2025-06-01 - UPDATED, Major edit to fix #333 [improper masking], bug fixes, needle updates, enhancement, and general code refactor

	TODO
		Better support for comment/string masking to avoid conflicts between them
		Add more support for Continuation sections - detection, conversion, restoration (set of Classes supporting different types?)
		Add support of other types of blocks/commands, etc.
		Add interctive component to prompt user for decisions?
		Refactor for separate support for v1.0 -> v1.1, and v1.1 -> v2

*/

global	  gTagChar		:= chr(0x2605) ; '★'																	; unique char to ensure tags are unique
;		, gNull			:= gTagChar 'NULL' gTagChar
		, gTagPfx		:= '#TAG' . gTagChar																	; common tag-prefix
		, gTagTrl		:= gTagChar . '#'																		; common tag-trailer
;		, gFilePath		:= '', gTestResCnt := 0	; TEMP

; global needles that can be used from anywhere within project
		; 2025-06-01 AMB, UPDATED - target non-escaped semicolons with leading ws or at beginning of string
		, gnLineComment	:= '(?<=^|\s)(?<!``);[^\v]*+'															; line comment (allows lead ws to be consumed already)
;		, gnLineComment	:= '(?m).*\K(?<=^|\h)(?<!``);.*$'			; very last occurence on any line			; POOR Efficiency
;		, gnLineComment	:= '(?m)(?<=^|\h)(?<!``);[^;\v]*+(?=\v|\z)'	; very last occurence on any line			; FAR MORE EFFICIENT
		, gPtn_LC		:= '(*UCP)(?m)' . gnLineComment															; line comments found on any line
;		, gPtn_LC		:= '(*UCP)(?m)(?<=\s|)(?<!``);[^\v]*'													; line comments found on any line
		, gPtn_BC		:= '(*UCP)(?m)^\h*(/\*((?>[^*/]+|\*[^/]|/[^*])*)(?>(?-2)(?-1))*(?:\*/|\Z))'				; block comments
;		, gPtn_ContBlk	:= '(?s)^(\R+\(\R+)(.+?)((?:\r\n)+\))$'													; basic continuation (parentheses) block [for reference]
;		, gPtn_BrcBlk	:= '(\{(?>[^}{]+|(?-1))*\})'															; nested brace blocks (for future support)
		, gPtn_KVO		:= '\{(?<KV>[^:\v]+:[^,\v]+,?)+\}'														; {key1:val1,key2:val2} obects
		, gPtn_PrnthBlk	:= '(?<FcParth>\((?<FcParams>(?>[^)(]+|(?-2))*)\))'		; very general					; nested parentheses block, single or multi-line
		, gPtn_PrnthML	:= '\(\R(?>[^\v\))]+|(?<!\n)\)|\R)*?\R\h*\)'			; very general					; nested parentheses block, MULTI-LINE ONLY
		, gPtn_FuncCall := '(?im)(?<FcName>[_a-z]\w*+)' . gPtn_PrnthBlk											; function call (supports ml and nested parentheses)
		, gPtn_FUNC		:= buildPtn_FUNC()																		; function block (supports nesting)
		, gPtn_CLASS	:= buildPtn_CLS()																		; class block (supports nesting)
		, gPtn_V1L_MLSV	:= buildPtn_V1LegMLSV()																	; v1 legacy (non expression) multi-line string assignment
;		, gPtn_IF		:= buildPtn_IF()																		; 2024-08-06 AMB, ADDED - IF blocks
;		, gPtn_LBLDecl	:= '^\h*+(?<name>[^;,\s``]+)(?<!:):(?!:)'												; 2025-06-01 AMB, ADDED - Label declaration
		, gPtn_LBLDecl	:= '^\h*(?<decl>(?::{0,2}(?:[^:,``\s]++|``[;%])++:(?!:))+)' ;(?=\h*$)'					; 2025-06-01 AMB, ADDED - Label declaration
		, gPtn_LblBLK	:= buildPtn_Label()																		; 2024-08-06 AMB, ADDED - label blocks
		, gPtn_HOTSTR	:= '^\h*+:(?<Opts>[^:\v]++)*+:(?<Trig>[^:\v]++)::'										; 2024-08-06 AMB, ADDED - hotstrings
		, gPtn_HOTKEY	:= buildPtn_Hotkey()																	; 2024-08-06 AMB, ADDED - hotkeys
		, gPtn_QS_1L	:= buildPtn_QStr()																		; DQ or SQ quoted-string, 1l (UPDATED 2025-06-01)
		, gPtn_DQ_1L	:= buildPtn_QS_DQ()																		; DQ-string, 1l (ADDED 2025-06-01)
		, gPtn_SQ_1L	:= buildPtn_QS_SQ()																		; SQ-string, 1l (ADDED 2025-06-01)
		, gPtn_QS_MLPth	:= buildPtn_MLQSPth()																	; quoted-string, ml (within parentheses)
		, gPtn_QS_ML	:= '(?<entry>:=\h*)\K"(([^"\v]++)\R)(?:\h*+[.|&,](?-2)*+)(?-1)++"'						; quoted-string, ml continuation (not within parentheses)
		, gHotKeyList	:= ''
		, gHotStrList	:= ''

;#########################################################################################################
;#########################################################################################################

;################################################################################
											  hasTag(srcStr := '', tagType := '')
;################################################################################
{
; 2025-06-01 AMB, ADDED
; Purpose: Convenient way to determine whether a string has...
;	A. a very specific tag		(tagType := exact tag to search for)
;		if srcStr is specified, this will only return a positive result if tag is found within srcStr
;		leave srcStr blank to guarantee a return of orig code from maskList, (even if tag is not found in srcStr)
;	B. a specific tag type		(tagtype := type of tag)
;	C. any mask tag in general	(tagType := leave empty)

	; A: find very specific mask-tag - return original code if found in maplist, false otherwise
	; (note: if srcStr is specified (not blank), will only return origCode if tag is ALSO found in srcStr)
	;	leave srcStr blank to return origCode regardless
	if (PreMask.maskList.has(tagType)) {
		oCode	:= PreMask.maskList[tagType].OrigCode
		retVal	:= (srcStr) ? ((srcStr ~= tagType) ? oCode : false) : oCode
		return	retVal
	}

	; setup for B: or C:
	tagType		.= (tagType) ? ((tagType ~= '^\w+_$') ? '' : '_') : ''	; if tagType is not blank, ensure its last char is underscore
	nTagType	:= '(?i)' uniqueTag(tagType '\w+')						; build tagType needle

	; B: find specific type of mask-tag
	; C: find any mask-tag in general
	; return first matching tag found, false otherwise
	retval	:= (srcStr) ? (RegExMatch(srcStr, nTagType, &mTag) ? mTag[] : false) : false
	return	retVal
;	return !!(srcStr ~= tagType)		; T or F
}

;#########################################################################################################
;#########################################################################################################

;################################################################################
class NodeMap	; 'block map' might be better term
{
; used for mapping and supporting details of code-blocks such as functions, classes, while, loop, if, etc
; supports relationships between nested blocks
; included to support tracking of local/global variables and modular-conversions

	name					:= ''		; name of block
;	taggedCode				:= ''		; (no longer used)
	BlockCode				:= ''		; orig block code - used to determine whether code was converted
	ConvCode				:= ''		; converted code
	cType					:= ''		; CLS, FUNC, etc
	tagId					:= ''		; unique tag Id
	parentPos				:= -1		; -1 is root
	pos						:= -1		; block start position within code, ALSO use as unique key for MapList
	len						:= 0		; char length of entire block
	ParentList				:= ''		; list of parent ids (immediate parent will be listed first)
	ChildList				:= map()	; list of child nodes

	; acts as constructor for a node object
	__New(name, cType, blkCode, pos, len)
	{
		this.name			:= name
		this.cType			:= cType
		this.blockCode		:= blkCode
		this.pos			:= pos
		this.len			:= len
	}

	; PRIVATE - returns the nested path depth of the node
	_depth() {
		StrReplace(this.PathVal, '\',,, &count)
		return count
	}

;	; PRIVATE - custom sort for path depth
;	_depthSort(a1,a2,*)
;	{
;		RegExMatch(a1, '(\d+):(\d+):', &m1)
;		RegExMatch(a2, '(\d+):(\d+):', &m2)
;		return ((m2[2] > m1[2]) ? 1 : ((m2[2] < m1[2]) ? -1 : ((m2[1] > m1[1]) ? 1 : ((m2[1] < m1[1]) ? -1 : 0))))
;	}

	; PUBLIC - convenience - returns string list of ChildList map()
	GetChildren() {
		cList := ''
		for key, childNode in this.ChildList {
			cList .= ((cList='') ? '' : ';') . ('[' key ']' . childNode.name)
		}
		return cList
	}

	EndPos					=> this.pos + this.len
	ParentName				=> (this.parentPos > 0)	 ? NodeMap.mapList[this.parentPos].name : 'Root'
	Path					=> ((this.parentPos > 0) ? NodeMap.mapList[this.parentPos].Path : '') . ('\' this.name)
	PathVal					=> ((this.parentPos > 0) ? NodeMap.mapList[this.parentPos].PathVal : '') . ('\' this.pos)
	AddChild(id)			=> this.ChildList[id]	:= NodeMap.mapList[id]	; add node object
	hasChildren				=> this.ChildList.Count
	hasChanged				=> (this.ConvCode && (this.ConvCode = this.BlockCode))

	;################################################################################

	static mapList			:= map()
	static idIndex			:= 0
	static nextIdx			=> ++NodeMap.IdIndex
	static getNode(id)		=> NodeMap.mapList(id)
	static getName(id)		=> NodeMap.mapList(id).name

	; PRIVATE - adds a node to maplist
	static _add(node) {
		NodeMap.mapList[node.pos] := node
		return
	}

	; PUBLIC - provides details of all nodes in maplist
	; used for debugging, etc.
	static Report() {
		reportStr := ''
		for key, nm in NodeMap.MapList {
			reportStr	.= '`nname:`t[' nm.cType '] ' nm.name '`nstart:`t' nm.pos '`nend:`t' nm.EndPos '`nlen:`t' nm.len
						. '`nparent:`t' nm.parentName ' [' nm.parentPos ']`npath:`t' nm.path '`npathV:`t' nm.pathVal '`nDepth:`t' nm.Depth()
						. '`nPList:`t' nm.parentList '`nChilds:`t' nm.getChildren() '`n'
		}
		return reportStr
	}

	; PUBLIC - builds a position map of all classes and functions found in script
	;	also identifies relationship between nodes
	static BuildNodeMap(code)
	{
		NodeMap.Reset()		; each build requires a fresh MapList

		; map all classes - including nested ones, from top to bottom
		pos := 0
		while(pos := RegExMatch(code, gPtn_CLASS, &m, pos+1)) {
			NodeMap._add(NodeMap(m.cname, 'CLS', m[], pos, m.len))
		}

		; map all functions - including nested ones, from top to bottom
		pos := 0
		while(pos := RegExMatch(code, gPtn_FUNC, &m, pos+1)) {
			if (m[]='')
				continue	; bypass IF/WHILE/LOOP
			NodeMap._add(NodeMap(m.fname, 'FUNC', m[], pos, m.len))
		}

		; identify parents and children for each node in maplist
		NodeMap._setKin()
		return
	}

	; PUBLIC - mask and convert classes and functions
	static MaskAndConvertNodes(&code)
	{
		; prep for tagging - get list of node positions
		nodeDepthStr := ''
		for key, node in NodeMap.mapList
			nodeDepthStr .= ((nodeDepthStr='') ? '' : '`n') . (key ':' node._depth() ':' node.name)

		; mask/tag each class and function, FROM BOTTOM TO TOP - REVERSE ORDER!
		reversedDepthStr := Sort(nodeDepthStr,'NR')
		Loop parse, reversedDepthStr, '`n', '`r'
		{
			; [pos] serves two purposes...
			;	1. starting char position of node [class,func,etc] within code body
			;	2. used as unique key for mapList[] (ensures map sort order is same as order found in code)
			pos		:= RegExReplace(A_LoopField, '^(\d+).+', '$1')	; extract pos/Key of current node
			node	:= nodeMap.mapList[number(pos)]

			; if node is a class
			if (node.cType='CLS')
			{
				mTag := uniqueTag('_CLS_P' pos), node.tagId := mTag
				if ((p:=RegExMatch(code, gPtn_CLASS, &m, pos))=pos)				; node position is known and specific
				{
					mCopy := m[]												; is premasked code - copy to prep for v2 conversion
					Restore_PreMask(&mCopy)										; remove premask of comments/strings (should now be orig)
					node.ConvCode := _convertLines(mCopy) ;,finalize:=0)		; now convert orig code to v2, store for final restoration
					; replace block of premasked code with block-tag
					code := RegExReplace(code, escRegexChars(m[]), mTag,,1,pos)	; 2025-06-01, part of Fix #333
				}
			}

			; if node is a function
			else if (node.cType='FUNC')
			{
				mTag := uniqueTag('_FUNC_P' pos), node.tagId := mTag
				if ((p:=RegExMatch(code, gPtn_FUNC, &m, pos))=pos)				; node position is known and specific
				{
					mCopy := m[]												; is premasked code - copy to prep for v2 conversion
					Restore_PreMask(&mCopy)										; remove premask of comments/strings/etc (should now be orig)
					node.ConvCode := _convertLines(mCopy) ;,finalize:=0)		; now convert orig code to v2, store for final restoration
					; replace block of premasked code with block-tag
					code := RegExReplace(code, escRegexChars(m[]), mTag,,1,pos)	; 2025-06-01, part of Fix #333
				}
			}
		}
		return
	}

	; PUBLIC - replaces class/func code with tags (indirectly)
	; converts original code in the process, stores it to be retrieved by Restore_Blocks()
	static Mask_Blocks(&code)
	{
		; pre-mask comments and strings
		Mask_PreMask(&code)									; might be redundant
		; mask classes and functions
		NodeMap.BuildNodeMap(code)							; prep for masking/conversion
		NodeMap.maskAndConvertNodes(&code)
		; remove premask from main/global code that will be converted normally
		Restore_PreMask(&code)
		return
	}

	; PUBLIC - replaces class/func code with v2 converted version (converted in MaskAndConvertNodes)
	static Restore_Blocks(&code)
	{
		for key, node in nodeMap.mapList {
			mTag		:= node.tagId
			convCode	:= node.convCode						; this code is already converted to v2 (see MaskAndConvertNodes)
;			code		:= StrReplace(code, mTag, convCode)		; would RegexReplace() have better performance?
			code		:= RegExReplace(code, mTag, convCode)	; TEST TO BE SURE NO NEEDLE CONFLICTS
		}
		return
	}

	; PRIVATE - identifies all parents/children for each node in nodelist
	static _setKin() {
		for key, node in NodeMap.mapList {
			node.ParentPos := NodeMap._findParents(node.name, node.pos, node.len)
		}
		return
	}

	; PRIVATE - find all parents/children for passed block, return immediate parent
	static _findParents(name, pos, len)
	{
		cp := -1, parentList := map()
		; find parent via brute force (by comparing code positions)
		for key, node in NodeMap.mapList {
			if ((pos>node.pos) && ((pos+len)<node.EndPos)) {
				offset				:= pos-node.pos				; looking for lowest offset (closest parent)
				parentList[offset]	:= node.pos					; add current parent id to list
				node.AddChild(pos)								; add this node to the ChildList of parent
				cp := ((cp < 0 || offset < cp) ? offset : cp)	; identify immediate (closest) parent
			}
		}
		; if no parent found, root is the parent
		if (cp<0) {
			NodeMap.mapList[pos].parentList := 'r'				; add root as only parent
			return -1											; -1 indicates root as only parent
		}
		; has at least 1 parent, save parent list, return immediate parent (pos)
		pList := parentList[cp] . ''
		for idx, parent in parentList {
			if (!InStr(pList, parent))
				pList .= ';' parent
		}
		pList .= ';r'				; add root
		NodeMap.mapList[pos].parentList := pList
		return parentList[cp]		; pos is used as mapList [key]
	}

	; PUBLIC - clears maplist
	static Reset()
	{
		nodeMap.mapList := Map()
		return
	}
}
;################################################################################
class PreMask
{
; handles masking of block/line comments and strings, and other general masking
; may add support for multi-line strings as required

	codePtn		:= ''
	maskType	:= ''
	origcode	:= ''
	mTag		:= ''

	__new(code, mTag, maskType, pattern)
	{
		this.origCode	:= code
		this.mTag		:= mTag
		this.maskType	:= maskType
		this.codePtn	:= pattern
	}

	;################################################################################

	static masklist		:= map()			; holds all premask objects, origCode/tags
	static uniqueIdList	:= map()			; ensures tags have unique ID
	;static maxMasks	:= 16**4			; 65K - CAUSED BUG!! NOT ENOUGH FOR HEAVY TESTING
	static maxMasks		:= 16**6			; 16.7 million (must be enough for heavy testing!!!)
	static maskCountT	:= 0				; 2025-06-01 - to prevent endless-loop bug


	; PRIVATE - removes tag record from maskList map
	static _deleteTag(tag)	; tag := list key
	{
		if (PreMask.masklist.has(tag)) {
			PreMask.maskList.Delete(tag)
		}
		return
	}

	; generates a unique 6bit hex value
	Static GenUniqueID()
	{
		while(true)
		{
			; make sure lockup (endless loop) does not occur (again)
			if (PreMask.maskCountT >= PreMask.maxMasks) {
				MsgBox('Fatal Error: Max number of masks (' PreMask.maxMasks ') have been used.`nEnding program!')
				ExitApp
			}
			; generate random 6 bit hex value (string)
			rnd	:= Random(1, PreMask.maxMasks), rHx	:= format('{:06}',Format('{:X}', rnd))	; 6 char hex string
			if (!PreMask.uniqueIdList.has(rHx)) {	; make sure value is not already in use
				PreMask.uniqueIdList[rHx] := true, PreMask.maskCountT++
				break
			}
		}
;		ToolTip('maskCount := ' PreMask.maskCountT, 10,10,10)
		return rHx
	}

	; PUBLIC - convenience/proxy method - mask block comments
	static Mask_BC(&code) {
		PreMask.MaskAll(&code, 'BC', gPtn_BC)
	}
	; PUBLIC - convenience/proxy method - mask line comments
	static Mask_LC(&code) {
		PreMask.MaskAll(&code, 'LC', gPtn_LC)
	}
	; PUBLIC - convenience/proxy method - mask hotkeys
	static Mask_HK(&code) {
		PreMask.MaskAll(&code, 'HK', gPtn_HOTKEY)
	}
	; PUBLIC - convenience/proxy method - mask hotstrings
	static Mask_HS(&code) {
		PreMask.MaskAll(&code, 'HS', gPtn_HOTSTR)
	}
	; PUBLIC - convenience/proxy method - mask label declarations
	static Mask_LBL(&code) {
		PreMask.MaskAll(&code, 'LBL', gPtn_LblDecl)
	}
	; PUBLIC - convenience/proxy method - mask key:val objects
	static Mask_KVO(&code) {
		PreMask.MaskAll(&code, 'KVO', gPtn_KVO)
	}
	; PUBLIC - convenience/proxy method - mask same-line quoted-strings (DQ or SQ)
	static Mask_QS(&code) {
		PreMask.MaskAll(&code, 'QS', gPtn_QS_1L)
	}
	; PUBLIC - convenience/proxy method - mask same-line DQ-strings
	static Mask_DQ(&code) {
		PreMask.MaskAll(&code, 'DQ', gPtn_DQ_1L)
	}
	; PUBLIC - convenience/proxy method - mask same-line SQ-strings
	static Mask_SQ(&code) {
		PreMask.MaskAll(&code, 'SQ', gPtn_SQ_1L)
	}
	; PUBLIC - convenience/proxy method - mask multi-line QUOTED-strings
	; 2025-06-01 AMB, ADDED, part of Fix #333 (regex needle is evolving)
	static Mask_MLQS(&code) {
		PreMask.MaskAll(&code, 'MLQS', gPtn_QS_MLPth)
	}
	; PUBLIC - convenience/proxy method - mask function calls
	static Mask_FC(&code, deleteTag:=true) {
		PreMask.Mask_FnCalls(&code, deleteTag)
	}

	; PUBLIC - convenience/proxy method - restore block comments
	static Restore_BC(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'BC', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore line comments
	static Restore_LC(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'LC', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore hotkeys
	static Restore_HK(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'HK', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore hotstrings
	static Restore_HS(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'HS', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore label declarations
	static Restore_LBL(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'LBL', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore key:val objects
	static Restore_KVO(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'KVO', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore same-line quoted-strings
	static Restore_QS(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'QS', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore same-line DQ-strings
	static Restore_DQ(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'DQ', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore same-line SQ-strings
	static Restore_SQ(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'SQ', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore multi-line QUOTED-strings
	; 2025-06-01 AMB, ADDED, part of Fix #333
	static Restore_MLQS(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'MLQS', deleteTag)
	}
	; PUBLIC - convenience/proxy method - restore function calls
	static Restore_FC(&code, deleteTag:=true) {
		PreMask.RestoreAll(&code, 'FC', deleteTag)
	}


	; PUBLIC - searches for pattern in code and masks the code
	; not for classes or functions - see dedicated methods for those
	static MaskAll(&code, maskType, pattern)
	{
		; search for target-code, replace code with tags, save original code
		pos := 1, uniqStr := ''
		while (pos := RegExMatch(code, pattern, &m, pos))
		{
			; record match details
			mCode := m[], mLen := m.Len

			; setup unique tag id - only generate as needed
			maskType	.= (maskType ~= '^\w+_$') ? '' : '_'							; ensure last char in maskType is underscore
			uniqStr		:= (uniqStr='') ? (maskType PreMask.GenUniqueID() '_') : uniqStr

			; create tag, and store orig code using premask object
			mTag					:= uniqueTag(uniqStr A_Index '_P' pos '_L' mLen)	; tag to be used for masking
			PreMask.masklist[mTag]	:= PreMask(mCode, mTag, maskType, pattern)			; create new PreMask object - add to mask list

			; 2025-06-01 AMB, UPDATED, part of Fix #333
			; StrReplace can replace the wrong occurence of mCode (wrong position) in some cases...
			;	(when that string is repeated more than once within the source code)
			; Use RegexReplace as default instead (which supports position)
			; Replace original code with a unique tag
			code	:= RegExReplace(code, escRegexChars(mCode), mTag,,1,pos)			; supports position
			pos		+= StrLen(mTag)														; set position for next search
		}
	}

	; PUBLIC - finds tags within code and replaces the tags with original code
	; OVERRIDE in sub-classes (for custom restores)
	static RestoreAll(&code, maskType, deleteTag:=true)
	{
		; setup unique tag id
		maskType	.= (maskType ~= '^\w+_$') ? '' : '_'		; ensure last char in maskType is underscore
		nMTag		:= uniqueTag(maskType '\w+')

		; search/replace tags with original code
		while (pos := RegExMatch(code, nMTag, &m))
		{
			mTag	:= m[]
			oCode	:= PreMask.masklist[mTag].origCode			; get original code (for current tag) from mask object
			code	:= StrReplace(code, mTag, oCode)			; replace current unique tag with original code
			; sometimes removes tags prematurely
			;	might need to fix this
			if (deleteTag) {
				PreMask._deleteTag(mTag)						; clean up, enhance performance?
			}
		}
	}

	; OVERRIDE in sub-classes (for custom conversions)
	static _convertCode(&code)
	{
	}
}
;################################################################################
class V1Leg_MLSV extends PreMask
{
; 2025-06-01 AMB, UPDATED to reflect proper purpose
; for V1 Legacy multi-line string assignemnts (non expression equals) including variable declaration


;	; 2025-06-01 AMB, ADDED for consistency
;	;	but is not used - V1Leg_MLSV utilizes internal call to parent class (PreMask) for Masking
;	; PUBLIC - searches for pattern in code and masks the code
;	; OVERRIDES PreMask MaskAll method
;	static MaskAll(&code, maskType, pattern)
;	{
;	}

	; PUBLIC - finds tags within code and replaces the tags with converted code
	; OVERRIDES PreMask RestoreAll method
	static RestoreAll(&code, maskType, convert:=true, deleteTag:=true)
	{
		; setup unique tag id
		maskType	.= (maskType ~= '^\w+_$') ? '' : '_'	; make sure last char in maskType is underscore
		nMTag		:= uniqueTag(maskType '\w+')
		; search/replace tags with original code
		while (pos := RegExMatch(code, nMTag, &m))			; position is unnecessary
		{
			mTag	:= m[]
			oCode	:= V1Leg_MLSV.masklist[mTag].origCode	; get original code (for current tag) from mask object
			if (convert) {
				V1Leg_MLSV._convertCode(&oCode)				; THIS STEP is the reason for a dedicated V1Leg_MLSV class
			}
			code	:= StrReplace(code, mTag, oCode)		; replace current unique tag with original code
			; sometimes removes tags prematurely
			;	might need to fix this
			if (deleteTag) {
				V1Leg_MLSV._deleteTag(mTag)					; clean up (PreMask.maskList), enhance performance?
			}
		}
	}

	; 2024-07-01, ADDED, AMB - fix for Issue #74
	; Overrides PreMask _convertCode method
	Static _convertCode(&code)
	{
		v2_ConvertV1L_MLSV(&code)
	}
}


;#########################################################################################################
;#########################################################################################################

;################################################################################
														v2_ConvertV1L_MLSV(&code)
;################################################################################
{
; 2025-06-01 AMB, MOVED and updated
; Purpose: Convert V1 Legacy multi-line string assignments, with variable declaration
; see the following for logic and needle (hopefully this covers all cases)
; needle tweaks are found in buildPtn_MLQSPth() and buildPtn_MLBlock in MaskCode.ahk
/*
	1. if is legacy = (yes always)
			convert = to  :=
	2. if guts contain %var%
			send each line to converter individually
			do not add quotes to exterior
		else
			leave guts alone (do not process)
			add quotes to exterior

	Legacy [=] multi-line block needle for reference	(?im)(?<decl>(?<var>[_a-z]\w*)\h*+`?=)(?im)(?<FullBlk>(?<entry>(?:(?&tag)|\h*+\R)++)(?<ParBlk>(?<mlOpts>(?<=^|\v)\h*+(?<!`)\(\h*+(?:(?:(?<TJ>[LR]TRIM[^\v\)]*+|JOIN[^\v\)]*+)|(?:(?:C(?:OM(?:MENTS?)?)?)?(?:\h(?&TJ))?(?<tag>\h*+#TAG★(?:LC|BC|QS)\w++★#)*+))))\R(?<guts>(?<cls>\s*+(?<!`)\))|(?<lines>\R*+[^\v]++)+?)(?(-2)|(?&cls))))
*/

	; parse code and convert v1 legacy multi-line to v2 expression multi-line
	pos := 1, convCode := code
	Restore_PreMask(&convCode)																			; chances are that... strings, comments, etc are masked
	nlegacyVar	:= 'im)%[_a-z]\w*%'																		; needle for %var%
	nDeclare	:= '^(?i)(\h*[_a-z]\w*\h*=)'															; needle for non-expression equals
	; find each occurence of... v1 legacy var assignment wih multi-line block
	while (pos	:= RegExMatch(convCode, gPtn_V1L_MLSV, &m, pos)) {
		outStr	:= '', mBlk := m[], blkLen := StrLen(mBlk)
		declare	:= m.decl, entry := m.entry, guts := m.guts, pBlk := m.ParBlk							; grab match parts
		; if block guts does NOT have a legacy %var%...
		;	change [=] to [:= "] , and add closing quote to end of block
		if (!(guts	 ~= nlegacyVar)) {																	; if block guts does NOT have a legacy %var%...
			declare	 := RegExReplace(declare, '=', ':= "')												; ... convert to expression and add begin quote
			pBlk	 .= '"'	; becomes )"																; [add ending quote to  )"]
			outStr	 := trim(declare . entry . pBlk, '`r`n')											; output string
		}
		; else, convert each line of block individually using _convertLines()
		else {
			varEquals	:= declare	 ; var =															; non-expression equals declaration
			expEquals	:= RegExReplace(varEquals, '=', ':=',,1)										; change = to := for needle
			outStr		:= ''																			; will be output string
			; convert each line of block indivdually by sending thru _convertLines()
			for idx, line in StrSplit(mBlk, '`n', '`r'){
				; if var declaration line (first line)
				if (idx=1 && (line~=nDeclare)) {														; if declaration line (first line)...
					outStr := expEquals																	; ... ensure declaration is :=
					continue																			; move to next line
				}
				; if NO %var% found on THIS line, convert normally
				if (!(line	~= nlegacyVar)) {															; if line does not have %var%...
					outStr	.= '`r`n' . trim(_convertLines(line), '`r`n')								; ... convert using _convertLines() directly
					continue																			; move to next line
				}
				; has %var% on THIS line - make adj and let _convertLines() handle it (convenience)
				RegExMatch(line, '^(?<LWS>\h*)(?<line_str>.*)$', &mLineParts)							; separate/preserve leading whitespce
				tempLine	:= varEquals . mLineParts.line_str											; add tempVar declaration for pass to _convertLines()
				convLine	:= trim(_convertLines(tempLine), '`r`n')									; convert templine to v2 expression
				; Remove tempVar declaration from converted output
				; 2025-06-01 - the conversion above doesn't always convert tempLine's = to :=
				; ... so, ensure BOTH 'tempVar =' AND 'tempVar :=' are removed, just in case
				convLine	:= RegExReplace(convLine, escRegexChars(varEquals)	'(.*)', '$1')			; 2025-06-01, part of Fix #333
				convLine	:= RegExReplace(convLine, escRegexChars(expEquals) 	'(.*)', '$1')			; 2025-06-01, part of Fix #333
				outStr		.= '`r`n' . mLineParts.LWS . convLine										; save line conversion results
			}
		}
		convCode := RegExReplace(convCode, escRegexChars(mBlk), outStr,,1) ;,pos) ; IS pos REQ HERE?	; update working var
		pos += StrLen(mBlk)																				; prep for next search/match
	}
	code := convCode
	return				; code by reference
}

;################################################################################
								 _getNodeNameList(code, nodeType, parentName:='')
;################################################################################
{
; 2024-07-07 AMB, ADDED
; intended to be used internally by this .ahk only
; TODO - MOVE TO NodeMap Class ?
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
; TODO - MOVE TO NodeMap Class ?
; returns a list of block nodes of requested type (FUNC, CLS, V1Leg_MLSV, etc)
; Those nodes contain the details of the particualr block
; 	additional details can then be extracted from those nodes

	Mask_PreMask(&code)				; pre-mask comments and strings
	NodeMap.BuildNodeMap(code)		; build node map

	; go thru node list and extract function names
	nodeList := []
	for key, node in NodeMap.mapList {
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

	return _getNodeNameList(code, 'CLS', parentName)
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

	return _getNodeNameList(code, 'FUNC', parentName)
}

;#########################################################################################################
;#########################################################################################################


;################################################################################
															   Mask_Blocks(&code)
;################################################################################
{
; proxy func to mask CLASSES and FUNCTIONS

	NodeMap.Mask_Blocks(&code)
	return	; code by reference
}
;################################################################################
															  Mask_PreMask(&code)
;################################################################################
{
; pre-mask block/line comments and strings
; necessary to remove characters that can interfere with...
;	detection of blocked code (classes, functions, etc)
; 2025-06-01 AMB, UPDATED - reordered as part of Fix #333
;	also removed Mask_MLQS for now

	; ORDER MATTERS!
	PreMask.Mask_BC(&code)		; mask block comments
;;	PreMask.Mask_LC(&code)		; mask line comments (WRONG ORDER)
	PreMask.Mask_QS(&code)		; mask quoted-strings - single-line
;	PreMask.Mask_MLQS(&code)	; mask quoted-strings - multi-line
	PreMask.Mask_LC(&code)		; mask line comments

	return	; code by reference
}
;################################################################################
																  Mask_BCs(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask block-comments

	PreMask.Mask_BC(&code)
	return	; code by reference
}
;################################################################################
																  Mask_LCs(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask line-comments

	PreMask.Mask_LC(&code)
	return	; code by reference
}
;################################################################################
															  Mask_Strings(&code)
;################################################################################
{
; 2024-04-08 AMB, ADDED
; 2024-06-02 AMB, UPDATED
; 2024-06-26 AMB, MOVED from ConvertFuncs.ahk. Just a proxy now
; 2025-06-01 AMB, UPDATED - part of Fix #333
;	support for multi-line QUOTED-strings in format "(string)" (removed for now)
; masks quoted-strings

	PreMask.Mask_QS(&code)		; mask single-line quoted strings
;	PreMask.Mask_MLQS(&code)	; mask multi--line quoted strings - removed for now
	return	; code by reference
}
;################################################################################
															Mask_DQstrings(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask DOUBLE-quoted strings on one line

	PreMask.Mask_DQ(&code)
	return	; code by reference
}
;################################################################################
															Mask_SQstrings(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask SINGLE-quoted strings on one line

	PreMask.Mask_SQ(&code)
	return	; code by reference
}
;################################################################################
															  Mask_HotKeys(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask hotkeys

	PreMask.Mask_HK(&code)
	return	; code by reference
}
;################################################################################
														   Mask_HotStrings(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask hotStrings

	PreMask.Mask_HS(&code)
	return	; code by reference
}
;################################################################################
															   Mask_Labels(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to mask label declarations

	PreMask.Mask_LBL(&code)
	return	; code by reference
}
;################################################################################
										 Mask_KVObjects(&code,restoreStrs:=false)
;################################################################################
{
; 2025-06-01 AMB, ADDED - mask key:val objects {key1:val1,key2:val2}

	Mask_PreMask(&code)	; pre-mask comments and strings
	PreMask.Mask_KVO(&code)
	; don't do this by default
	if (restoreStrs)
		Restore_Strings(&code)
	return	; code by reference
}
;################################################################################
															Mask_V1LegMLSV(&code)
;################################################################################
{
; 2024-06-30 AMB, ADDED
; masks V1 legacy (non-expression) multi-line string assignments
; V1Leg_MLSV class is used for custom convert and restore, but not masking
; called from Before_LineConverts() of ConvertFuncs.ahk

	Mask_PreMask(&code)	; pre-mask comments and strings
	V1Leg_MLSV.MaskAll(&code, 'V1Leg_MLSV', gPtn_V1L_MLSV)	; internally uses Premask.MaskAll
	return	; code by reference
}
;################################################################################
															Mask_MLParenth(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED
; masks (general) multi-line continuation blocks (surrounded by parentheses)
; TODO - WORK/TESTING IN PROGRESS !

	Mask_PreMask(&code)	; pre-mask comments and strings

	nMLParenth := buildPtn_MLBlock().parBlk
;	A_Clipboard := nMLParenth
;	ExitApp
	PreMask.MaskAll(&code, 'MLGenCont', nMLParenth)
;	PreMask.MaskAll(&code, 'MLGenCont', gPtn_PrnthML)
	return	; code by reference
}
;################################################################################
										Mask_FuncCalls(&code, restoreStrs:=false)
;################################################################################
{
; 2025-06-01 AMB, UPDATED - added code directly to this func, rather than acting as proxy
; masks all function CALLS found within passed code string

	Mask_Strings(&code)	; pre-mask comments and strings										; to prevent func detection issues
;	nestedParentheses	:= '(\((?>[^)(]+|(?-1))*\))'										; single or multi-line, nested parentheses
;	nFuncCall			:= '(?im)[_a-z]\w*+' nestedParentheses								; any func call, single or multi-line
	funcCount			:= 0, pos := 0
	while (pos	:= RegExMatch(code, gPtn_FuncCall, &m, pos+1)) {							; find all function calls within passed code
		curMFC	:= m[]																		; note: all strings in match have been premasked
		origFC	:= curMFC, Restore_Strings(&origFC)											; restore orig strings within func calls only
		uniqStr					:= 'FC_' PreMask.GenUniqueID() '_' (++funcCount)			; [unique tag string]
		mTag					:= uniqueTag(uniqStr)										; create unique tag
		PreMask.masklist[mTag]	:= PreMask(origFC, mTag, 'FC', '')							; store new Premask object within Premask-list
		code					:= RegExReplace(code, escRegexChars(curMFC), mTag,,1,pos)	; update code with tag, replacing current masked FC
		pos						+= StrLen(mtag)												; prep for next search/interation
	}

	; don't do this by default
	if (restoreStrs)
		Restore_Strings(&code)

	return	; code by reference
}


;#########################################################################################################
;#########################################################################################################



;################################################################################
															Restore_Blocks(&code)
;################################################################################
{
; proxy func to restore CLASSES and FUNCTIONS

	NodeMap.Restore_Blocks(&code)
	return	; code by reference
}
;################################################################################
														   Restore_PreMask(&code)
;################################################################################
{
; restore comments and strings that were premasked
; 2025-06-01 AMB, UPDATED - part of Fix #333

	; ORDER MATTERS!			(must be in reverse of masking)
	PreMask.Restore_LC(&code)	; restore line comments
	PreMask.Restore_MLQS(&code)	; restore quoted-strings - multi-line
	PreMask.Restore_QS(&code)	; restore quoted-strings - single-line
;	PreMask.Restore_LC(&code)	; restore line comments (WRONG ORDER)
	PreMask.Restore_BC(&code)	; restore block comments
	return						; code by reference
}
;################################################################################
															   Restore_BCs(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore block-comments

	PreMask.Restore_BC(&code)
	return	; code by reference
}
;################################################################################
															   Restore_LCs(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore line-comments

	PreMask.Restore_LC(&code)
	return	; code by reference
}
;################################################################################
										  Restore_Strings(&code, deleteTag:=true)
;################################################################################
{
; 2024-04-08 AMB, ADDED
; 2024-06-26 AMB, MOVED from ConvertFuncs.ahk. Just a proxy now
; 2025-06-01 AMB, UPDATED - part of Fix #333 - support for multi-line QUOTED-strings in format "(string)"
; restores orig strings that were masked by Mask_Strings()

	PreMask.Restore_MLQS(&code, deleteTag)
	PreMask.Restore_QS(&code, deleteTag)
	return	; code by reference
}
;################################################################################
										Restore_DQstrings(&code, deleteTag:=true)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore DOUBLE-quoted strings on one line

	PreMask.Restore_DQ(&code, deleteTag)
	return	; code by reference
}
;################################################################################
										Restore_SQstrings(&code, deleteTag:=true)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore SINGLE-quoted strings on one line

	PreMask.Restore_SQ(&code, deleteTag)
	return	; code by reference
}
;################################################################################
										  Restore_HotKeys(&code, deleteTag:=true)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore hotkeys

	PreMask.Restore_HK(&code, deleteTag)
	return	; code by reference
}
;################################################################################
									   Restore_HotStrings(&code, deleteTag:=true)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore hotStrings

	PreMask.Restore_HS(&code, deleteTag)
	return	; code by reference
}
;################################################################################
										   Restore_Labels(&code, deleteTag:=true)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore label declarations

	PreMask.Restore_LBL(&code, deleteTag)
	return	; code by reference
}
;################################################################################
										Restore_KVObjects(&code, deleteTag:=true)
;################################################################################
{
; 2025-06-01 AMB, ADDED - proxy func to restore key:val objects {key1:val1,key2:val2}

	PreMask.Restore_KVO(&code, deleteTag)
	return	; code by reference
}
;################################################################################
						 Restore_V1LegMLSV(&code, convert:=true, deleteTag:=true)
;################################################################################
{
; 2024-06-30 AMB, ADDED
; restore V1 legacy (non-expression) multi-line string assignments
; V1Leg_MLSV class is used for custom convert and restore, but not masking
; called from After_LineConverts() of ConvertFuncs.ahk

	V1Leg_MLSV.RestoreAll(&code, 'V1Leg_MLSV', convert, deleteTag)	; converts to v2 as part of restore
	return	; code by reference
}
;################################################################################
										Restore_MLParenth(&code, deleteTag:=true)
;################################################################################
{
; 2024-06-30 AMB, ADDED
; restore (general) multi-line continuation blocks (surrounded by parentheses)

	PreMask.RestoreAll(&code, 'MLGenCont', deleteTag)	; DOES NOT convert to v2 as part of restore
	return	; code by reference
}
;################################################################################
										Restore_FuncCalls(&code, deleteTag:=true)
;################################################################################
{
; proxy func to restore function calls

	PreMask.Restore_FC(&code, deleteTag)
	return	; code by reference
}


;#########################################################################################################
;#########################################################################################################


;################################################################################
																 Remove_BCs(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove block comments from passed code

	return RegExReplace(code,gPtn_BC)	; remove block comments
}
;################################################################################
																 Remove_LCs(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove line comments from passed code
; 2025-06-01 AMB, UPDATED - to prevent conflicts with " ;" within strings

	; Mask strings first to prevent accidents for strings
	Mask_Strings(&code)
	code := RegExReplace(code,gPtn_LC)	; remove line  comments
	Restore_Strings(&code)
	return code
}
;################################################################################
															Remove_Comments(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove block and line comments from passed code

	code := Remove_BCs(code)				; remove block comments
	return	Remove_LCs(code)				; remove line  comments
}
;################################################################################
														   Remove_V1LegMLSV(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove V1 Legacy multi-line strings from passed code

	return RegExReplace(code, gPtn_V1L_MLSV)
}



;#########################################################################################################
;#########################################################################################################



;################################################################################
															 uniqueTag(uniqueStr)
;################################################################################
{
; 2025-06-01 AMB, ADDED - returns unique tag based on passed unique-string
;	see top of this file for global var declaration
;	global	  gTagChar	:= chr(0x2605) ; '★'
;			, gTagPfx	:= '#TAG' gTagChar
;			, gTagTrl	:= gTagChar '#'

	return gTagPfx . uniqueStr . gTagTrl
}
;################################################################################
															escRegexChars(srcStr)
;################################################################################
{
; 2025-06-01 AMB, ADDED, part of Fix #333
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
														  hasValidV1Label(srcStr)
;################################################################################
{
; 2025-06-01 AMB, ADDED
; returns srcStr if any valid v1 label is found in string
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_LBLDecl for label declaration needle

	tempStr := trim(Remove_LCs(srcStr))	; remove line comments and trim ws

	; return full string if valid v1 label is found anywhere in string
	if (tempStr ~= '(?m)' . gPtn_LblBLK)	; multi-line check
		return srcStr		; appears to have valid v1 label somewhere
	return ''				; no valid v1 label found in srcStr
}
;################################################################################
														   isValidV1Label(srcStr)
;################################################################################
{
; 2025-06-01 AMB, ADDED
; returns extracted label if it resembles a valid v1 label
; 	does not verify that it is a valid v2 label (see validV2Label for that)
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_LBLDecl for label declaration needle

	tempStr := trim(Remove_LCs(srcStr))	; remove line comments and trim ws

	; return just the label if it resembles a valid v1 label
	if (RegExMatch(tempStr, gPtn_LblBLK, &m))	; single-line check
		return m[1]			; appears to be valid v1 label
	return ''				; not a valid v1 label
}
;################################################################################
				   StrReplaceAt(haystack, needle, repl, cs:=0, pos:=1, limit:=-1)
;################################################################################
{
; 2025-06-01 AMB, ADDED, part of Fix #333 (use as needed)
; adds position support for StrReplace
; BUT... is extremely SLOW!! Use sparingly (use RegexReplace instead, if possible)
; TODO - CURRENTLY NOT USED

	lead		:= SubStr(haystack, 1, pos - 1)
	trail		:= SubStr(haystack, pos)
	newTrail	:= StrReplace(trail, needle, repl, cs,, limit)
	return		lead . newTrail
}
;################################################################################
																literalRegex(str)
;################################################################################
{
; 2025-06-01 AMB, ADDED, part of Fix #333 (use as needed)
; TODO - CURRENTLY NOT USED - use escRegexChars() instead

	return '\Q' StrReplace(str, '\E', '\E\\E\Q') '\E'
}
;################################################################################
															  getScriptVer(&code)
;################################################################################
{
; 2025-06-01 AMB, ADDED
; TODO - WORK IN PROGRESS - CURRENTLY NOT USED
; inspects code to determine which AHK version it appears to be
; returns
;	10 for v1.0 (legacy)
;	11 for v1.1 (cur v1)
;	20 for v2.0+
;	0 for unknown

;	Also see for more info
;	'script code version 04-14.011.ahk'
;	'Pre-process ahk files 01e.ahk'
;	'Script Converter stuff 01.ahk'

	nV_1_0 := '														; v1 legacy
	(c
	#(?:commentflag|delimiter|(?:deref|escape)char)					; directives
	\bif(?:not)?equal(?:,|\h+%)										; legacy if 1
	\bif(?:not)?exist(?:,|\h+%)										; legacy if 2
	\bif(?:not)?instring(?:,|\h+%)									; legacy if 3
	\bif(?:less|greater)(?:orequal)?(?:,|\h+%)						; legacy if 4
	\bifwin(?:not)?(?:active|exist)(?:,|\h+%)						; legacy if 5
	\bcomobj(?:[eu]nwrap|missing|parameter)\h*\(					; ComObj
	\b(?:env(?:div|mult)|set(?:env|format))							; deprecated cmds
	\b(?:onexit|getKeyState)\h*(?!\()(?!:)(?:,|\h+%)				; cmds that are not funcs
	\bsplash(?:text(?:on|off)|image)								; splash variants
	\bstring(?:getpos|len|mid|replace|split|(trim)?(?:left|right))	; string variants
;	\b(?:progress|transform)										; could conflict with user defined
	)'

	nV_1_1 := '														; v1 expression
	(c
	#(?:noenv|persistent|singleinstance,)							; common directives
	\b(?:sleep|msgbox|loop|gui|run|while|return)(?:,|\h+%)			; common cmds	- followed by , or %
	\b(?:CoordMode|Critical|gui|Hotkey|InputBox)(?:,|\h+%)			; common cmds	- followed by , or %
	\b(?:Mouse(?:GetPos|move)(?:,|\h+%)								; common cmds	- followed by , or %
	\b(?:DetectHiddenWindows|SetTimer|SetWorkingDir)(?:,|\h+%)		; common cmds	- followed by , or %
	\b(?:Pause|Sort|SoundBeep|SplitPath|Thread|WinSet)(?:,|\h+%)	; common cmds	- followed by , or %
	\b(?:WinGet(?:class|pos|title)?(?:,|\h+%)						; common cmds	- followed by , or %
	\bsend(?:message|event|input|play)?(?:,|\h+%)					; send variants	- followed by , or %
	\b(?:IfMsgBox|VarSetCapacity)\b
	\.maxindex\(\)
	\blv_(?:delete|insert|modify)(?:col)?							; LV methods 1
	\blv_(?:get(?:count|next|text)|setimagelist)					; LV methods 2
	\bahk_(?:id|exe)\h+%\w+%										; ahk_xxx, not in quotes, with v1 var
	)'

	nV_2_0 := '		; WORK IN PROGRESS
	(c
	)'

	/*
	v1
	% "ahk_id "

	v2
	buffer()
	map()
	Integer()
	fileRead()
	functions with pointer vars
	regexMatch with pointer var
	static methods/functions
	'string' (single-quote strings
	.DefineProp
	coordMode with strings

	*/

	; requires directive (v1 or 2)
	if (RegExMatch(code, '(?im)^\h*+\K#REQUIRES\h++AUTOHOTKEY\h++v?[><=]*(\d).*+', &m))
		return (m[1]<2) ? 11 : 20

	; v1.0 clues
	needles := StrSplit(nV_1_0, '`n', '`r')
	for idx, needle in needles
	{
		if (code ~= '(?im)' needle)
			return 10
	}
	; v1.1 clues
	needles := StrSplit(nV_1_1, '`n', '`r')
	for idx, needle in needles
	{
		if (code ~= '(?im)' needle)
			return 11
	}
;	nFuncCalls := '(?im)[_a-z]\w*+(\((?>[^)(]+|(?-1))*\))'
	pos := 0
	while (pos := RegExMatch(code, gPtn_FuncCall, &m, pos+1))
	{
		match := StrLower(m[])
		if (InStr(match, 'byref'))
			return 11
		pos += StrLen(match)
	}


;	; v2 clues
;	needles := StrSplit(nV_2_0, '`n', '`r')
;	for idx, needle in needles
;	{
;		if (code ~= '(?im)' needle)
;			return 20
;	}

	return false	; unknown


;	Restore_PreMask(&code)
;	code := Remove_BCs(code)
;	code := Remove_LCs(code)
;	PreMask.MaskAll(&code, 'DQStr', buildPtn_QS_DQ())
;	; v2 single-quote strings
;	if (RegExMatch(code, buildPtn_QS_SQ(), &m))
;	{
;		match := m[]
;		SplitPath gFilePath, &FName, &dir, &ext, &FnNoExt, &drv
;		matchCount++
;		gFileList .= gFilePath '`r`n' match '`r`n'
;;		MsgBox "[" gFileList "]"
;		newFN := 'C:\Users\notch\Desktop\All Scripts 2025-05-08.073\sorted\V2\' FName
;		FileMove(gFilePath, newFN)
;		ToolTip(matchCount, 10, A_ScreenHeight-300, 13)
;	}

/*

Commands := {KeyNames:"Alt AppsKey Backspace Break Browser_Back Browser_Favorites Browser_Forward Browser_Home Browser_Refresh Browser_Search Browser_Stop CapsLock Control CtrlBreak Delete Down End Enter Escape F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24 Help Home Insert LAlt Launch_App1 Launch_App2 Launch_Mail Launch_Media LButton LControl Left LShift LWin MButton Media_Next Media_Play_Pause Media_Prev Media_Stop NumLock Numpad Numpad0 Numpad1 Numpad2 Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 Numpad9 NumpadAdd NumpadAdd NumpadClear NumpadDel NumpadDiv NumpadDiv NumpadDot NumpadDown NumpadEnd NumpadEnter NumpadEnter NumpadHome NumpadIns NumpadLeft NumpadMult NumpadMult NumpadPgDn NumpadPgUp NumpadRight NumpadSub NumpadSub NumpadUp Pause PgDn PgUp PrintScreen RAlt RButton RControl Right RShift RWin ScrollLock Shift Space Tab Up Volume_Down Volume_Mute Volume_Up WheelDown WheelLeft WheelRight WheelUp XButton1 XButton2"
,Directives:"#ClipboardTimeout #CommentFlag #ErrorStdOut #EscapeChar #HotkeyInterval #HotkeyModifierTimeout #Hotstring #If #IfTimeout #IfWinActive #IfWinExist #Include #InputLevel #InstallKeybdHook #InstallMouseHook #KeyHistory #MaxHotkeysPerInterval #MaxMem #MaxThreads #MaxThreadsBuffer #MaxThreadsPerHotkey #MenuMaskKey #NoEnv #NoTrayIcon #Persistent #SingleInstance #UseHook #Warn #WinActivateForce"
,Indent:"Catch else for Finally if IfEqual IfExist IfGreater IfGreaterOrEqual IfInString IfLess IfLessOrEqual IfMsgBox IfNotEqual IfNotExist IfNotInString IfWinActive IfWinExist IfWinNotActive IfWinNotExist Loop Try while"
,BuiltIn:"A_AhkPath A_ScriptHwnd A_AhkVersion A_AppData A_AppDataCommon A_AutoTrim A_BatchLines A_CaretX A_CaretY A_ComputerName A_ControlDelay A_Cursor A_DD A_DDD A_DDDD A_DefaultMouseSpeed A_Desktop A_DesktopCommon A_DetectHiddenText A_DetectHiddenWindows A_EndChar A_EventInfo A_ExitReason A_FormatFloat A_FormatInteger A_Gui A_GuiControl A_GuiControlEvent A_GuiEvent A_GuiHeight A_GuiWidth A_GuiX A_GuiY A_Hour A_IconFile A_IconHidden A_IconNumber A_IconTip A_Index A_IPAddress1 A_IPAddress2 A_IPAddress3 A_IPAddress4 A_IsAdmin A_IsCompiled A_IsCritical A_IsPaused A_IsSuspended A_IsUnicode A_KeyDelay A_Language A_LastError A_LineFile A_LineNumber A_LoopField A_LoopFileAttrib A_LoopFileDir A_LoopFileExt A_LoopFileFullPath A_LoopFileLongPath A_LoopFileName A_LoopFileShortName A_LoopFileShortPath A_LoopFileSize A_LoopFileSizeKB A_LoopFileSizeMB A_LoopFileTimeAccessed A_LoopFileTimeCreated A_LoopFileTimeModified A_LoopReadLine A_LoopRegKey A_LoopRegName A_LoopRegSubkey A_LoopRegTimeModified A_LoopRegType A_MDAY A_Min A_MM A_MMM A_MMMM A_Mon A_MouseDelay A_MSec A_MyDocuments A_Now A_NowUTC A_NumBatchLines A_OSType A_OSVersion A_PriorHotkey A_ProgramFiles A_Programs A_ProgramsCommon A_PtrSize A_ScreenHeight A_ScreenWidth A_ScriptDir A_ScriptFullPath A_ScriptName A_Sec A_Space A_StartMenu A_StartMenuCommon A_Startup A_StartupCommon A_StringCaseSense A_Tab A_Temp A_ThisFunc A_ThisHotkey A_ThisLabel A_ThisMenu A_ThisMenuItem A_ThisMenuItemPos A_TickCount A_TimeIdle A_TimeIdlePhysical A_TimeSincePriorHotkey A_TimeSinceThisHotkey A_TitleMatchMode A_TitleMatchModeSpeed A_UserName A_WDay A_WinDelay A_WinDir A_WorkingDir A_YDay A_YEAR A_YWeek A_YYYY true false"
,Commands:"AutoTrim BlockInput Click ClipWait Control ControlClick ControlFocus ControlGet ControlGetFocus ControlGetPos ControlGetText ControlMove ControlSend ControlSetText CoordMode DetectHiddenText DetectHiddenWindows Drive DriveGet DriveSpaceFree Edit EnvAdd EnvDiv EnvGet EnvMult EnvSet EnvSub EnvUpdate FileAppend FileCopy FileCopyDir FileCreateDir FileCreateShortcut FileDelete FileEncoding FileInstall FileGetAttrib FileGetShortcut FileGetSize FileGetTime FileGetVersion FileMove FileMoveDir FileOpen FileRead FileReadLine FileRecycle FileRecycleEmpty FileRemoveDir FileSelectFile FileSelectFolder FileSetAttrib FileSetTime FormatTime GetKeyState GroupActivate GroupAdd GroupClose GroupDeactivate Gui GuiControl GuiControlGet Hotkey ImageSearch IniDelete IniRead IniWrite Input InputBox KeyHistory KeyWait ListHotkeys ListLines ListVars #LTrim Menu MouseClick MouseClickDrag MouseGetPos MouseMove MsgBox OnClipboardChange OutputDebug Pause PixelGetColor PixelSearch PostMessage Process Progress Random RegDelete RegRead RegWrite Reload Run RunAs RunWait Sleep Send SendRaw SendInput SendPlay SendLevel SendMessage SendMode SetCapslockState SetControlDelay SetDefaultMouseSpeed SetEnv SetFormat SetKeyDelay SetMouseDelay SetNumlockState SetScrollLockState SetRegView SetStoreCapslockMode SetTitleMatchMode SetWinDelay SetWorkingDir Shutdown Sort SoundBeep SoundGet SoundGetWaveVolume SoundPlay SoundSet SoundSetWaveVolume SplashImage SplashTextOn SplashTextOff SplitPath StatusBarGetText StatusBarWait StringCaseSense StringGetPos StringLeft StringLen StringLower StringMid StringReplace StringRight StringSplit StringTrimLeft StringTrimRight StringUpper SysGet ToolTip Transform TrayTip Trim UrlDownloadToFile WinActivate WinActivateBottom WinClose WinGetActiveStats WinGetActiveTitle WinGetClass WinGet WinGetPos WinGetText WinGetTitle WinHide WinKill WinMaximize WinMenuSelectItem WinMinimize WinMinimizeAll WinMinimizeAll Undo WinMove WinRestore WinSet WinSetTitle WinShow WinWait WinWaitActive WinWaitClose WinWaitNotActive"
,Functions:"Abs Asc ACos ASin ATan Ceil Chr ComObjActive ComObjArray ComObjConnect ComObjCreate ComObjEnwrap ComObjError ComObjFlags ComObjGet ComObjMissing ComObjParameter ComObjQuery ComObjType ComObjValue Cos DllCall Exp FileExist Floor Func GetKeyName GetKeySC GetKeyVK InStr IsByRef IsFunc IsLabel IsObject Ln Log Mod NumGet NumPut OnMessage RegExMatch RegExReplace RegisterCallback Round Sin Sqrt StrGet StrLen StrPut StrSplit SubStr Tan VarSetCapacity WinExist"
,Keywords:"Abort AboveNormal Add ahk_class ahk_group ahk_id ahk_pid All alnum alpha AltDown AltSubmit AltTab AltTabAndMenu AltTabMenu AltTabMenuDismiss AltUp AlwaysOnTop and AutoHDR AutoSize Background BackgroundTrans BelowNormal between BitAnd BitNot BitOr BitShiftLeft BitShiftRight BitXOr Blind bold Border Bottom Button Buttons ByRef Cancel Capacity Caption Center Check Check3 Checkbox Checked CheckedGray Choose ChooseString Clipboard ClipboardAll Close Color ComboBox ComSpec contains ControlList Count CtrlDown CtrlUp date DateTime Days DDL Default DeleteAll Delimiter Deref Destroy digit Disable Disabled DropDownList Eject Enable Enabled Error ErrorLevel Exist Expand ExStyle FileSystem First Flash Float FloatFast Focus Font FromCodePage global Grid Group GroupBox GuiClose GuiContextMenu GuiDropFiles GuiEscape GuiSize Hdr Hidden Hide High HKCC HKCR HKCU HKEY_CLASSES_ROOT HKEY_CURRENT_CONFIG HKEY_CURRENT_USER HKEY_LOCAL_MACHINE HKEY_USERS HKLM HKU Hours HScroll Icon IconSmall ID IDLast Ignore ImageList in Integer IntegerFast Interrupt italic Join Label LastFound LastFoundExist Limit Lines List ListBox ListView local LocalSameAsGlobal Lock Logoff Low lower Lowercase MainWindow Margin Maximize MaximizeBox MaxSize Minimize MinimizeBox MinMax MinSize Minutes MonthCal Mouse Move Multi NA No NoActivate NoDefault NoHide NoIcon NoMainWindow norm Normal NoSort NoSortHdr NoStandard not NoTab NoTimers number Off Ok On or OwnDialogs Owner Parse Password Pic Picture Pixel Pos Pow Priority ProcessName ProgramFiles Radio Range Raw Read ReadOnly Realtime Redraw REG_BINARY REG_DWORD REG_EXPAND_SZ REG_MULTI_SZ REG_SZ Region Relative Remove Rename Report Resize Restore Retry RGB RWinDown RWinUp Screen Seconds Section Select Serial SetLabel ShiftAltTab ShiftDown ShiftUp Show Single Slider SortDesc ss Standard static Status StatusBar StatusCD strike Style Submit SysMenu Tab2 TabStop Text Theme Tile time Tip ToCodePage ToggleCheck ToggleEnable ToolWindow Top Topmost TransColor Transparent Tray TreeView TryAgain Type UnCheck underline Unicode Unlock UpDown upper Uppercase UseEnv UseErrorLevel UseUnsetGlobal UseUnsetLocal Vis VisFirst Visible VScroll Wait WaitClose WantCtrlA WantF2 WantReturn WinMinimizeAllUndo Wrap xdigit xm xp xs Yes ym yp ys"
,Flow:"Break Continue Critical Exit ExitApp Gosub Goto OnExit Pause return SetBatchLines SetTimer Suspend Thread Throw Until"}

*/

}



;#########################################################################################################
;#########################################################################################################


;################################################################################
																 buildPtn_QS_DQ()
;################################################################################
{
; 2025-06-01 AMB, ADDED
; Single-line, DOUBLE-QUOTED strings [V1 or V2]

	return '(?<!``)(?<!")"(?>""|``"|````|``|[^"``\v]*+)*+"'
}
;################################################################################
																 buildPtn_QS_SQ()
;################################################################################
{
; 2025-06-01 AMB, ADDED
; Single-line, SINGLE-QUOTED strings [V2] (avoids apostrophe trigger)

	return '(?<!``)\B`'(?>```'|````|``|[^`'``\v]*+)*+`'\B'
}
;################################################################################
																  buildPtn_QStr()
;################################################################################
{
; 2025-06-01 AMB, ADDED to fix #333 (improper string masking)
; supports single-line, single/double-quoted strings (AHK v1 or v2)
; DOES NOT support v1 legacy (non-expression) strings

	return 	'(?:' buildPtn_QS_SQ() '|' buildPtn_QS_DQ() ')'	; combine single and double quotes
}
;################################################################################
															   buildPtn_MLBlock()
;################################################################################
{
;	2025-06-01 AMB, ADDED to support general multi-line blocks
;	NOTE: these needles are designed as VERY POSSESSIVE (for efficiency and avoid errors)

	opt 		:= '(?im)'																	; CALLER MUST ADD this needle option manually (ignore case, multi-line)
	TG			:= '(?<tag>\h*+#TAG★(?:LC|BC|QS)\w++★#)'									; mask tags (line/block comment or quoted-string ONLY!)
	entry		:= '(?<entry>(?:(?&tag)|\h*+\R)++)'											; any tags or CRLFs before opening parenthesis
;	mlOpt1		:= '(?:(?:(?<TJ>[LR]TRIM[^\v\)]*+|JOIN[^\v\)]*+)\R'							; ML string options (optional)
	mlOpt1		:= '(?:(?:(?<TJ>[LR]TRIM[^\v\)]*+|JOIN[^\v\)]*+)'							; ML string options (optional)
;	mlOpt2		:= '(?:(?:C(?:OM(?:MENTS?)?)?)?(?:\h(?&TJ))?' TG '*+)\R'					; ML string comment or tags (optional)
	mlOpt2		:= '(?:(?:C(?:OM(?:MENTS?)?)?)?(?:\h(?&TJ))?' TG '*+)'						; ML string comment or tags (optional)
	mlOpts		:= '(?<mlOpts>(?<=^|\v)\h*+(?<!``)\(\h*+' mlOpt1 '|' mlOpt2 ')))'			; all options for declaration line
	lines		:= '(?<lines>\R*+[^\v]++)+?'												; lines that follow open parenthesis (lazy - one at a time)
	cls			:= '(?<cls>\s*+(?<!``)\))'													; closing parenthesis
	guts		:= '(?<guts>' cls '|' lines ')'												; all lines, then close
;	parBlk		:= '(?<ParBlk>' mlOpts guts '(?(-2)|(?&cls)))'								; full body from open to close parentheses
	parBlk		:= '(?<ParBlk>' mlOpts '\R' guts '(?(-2)|(?&cls)))'							; full body from open to close parentheses
	fullBlk		:= '(?im)(?<FullBlk>' . entry . parBlk ')'									; full multi-line block, including general entry
;	pattern		:= opt . fullBlk															; only used for testing

	define		:= '(?im)(^|\R)' mlOpts
	nextLine	:= '[^\v]*+\R?'																; used in MaskAll of ML_Parenth class - for custom masking
	closer		:= '^(\h*(?<!``)\))[^\v]*+'													; used in MaskAll of ML_Parenth class - for custom masking

	return		{nOpt:opt,full:fullBlk,ParBlk:ParBlk,define:define,nextLine:nextLine,closer:closer}
}
;################################################################################
															 buildPtn_V1LegMLSV()
;################################################################################
{
; V1 Legacy multi-line string assignments (non-expression = ), NOT (:=)
; does not currently support block comments between declaration and opening parenthesis
;	may add this support later, as required
; 2024-07-07 AMB, UPDATED for better performance, updated comment needle to bypass escaped semicolon
; 2025-06-01 AMB, UPDATED to reflect actual purpose
;	This version will ONLY match assignments WITH VARIABLE NAME

	opt			:= '(?im)'
	entry		:= '(?<decl>(?<var>[_a-z]\w*)\h*+``?=)'		; var - variable name (required!)
	pattern		:= opt . entry . buildPtn_MLBlock().full	; 2025-06-01 - UPDATED block/body
	return		pattern
}
;################################################################################
															   buildPtn_MLQSPth()
;################################################################################
{
; supports multi-line single/double-quoted strings (AHK v1 or v2)
; supports multi-line v1 legacy (non-assignment) string-blocks
; can also support multi-line v1 legacy assignment string-blocks (but not by default)
; 	see buildPtn_V1LegMLSV() for supporting v1 legacy multi-line string assignments (with variable declaration)
; 2025-06-01, UPDATED to fix #333 (improper string masking)

	opt			:= '(?im)'
	entry		:= '(?:[:.]=|,|%)?\K\h*+("|\B`').*+'
	return		opt . entry . buildPtn_MLBlock().full . '\h*+(?1)'	; '"(string)"' misc formats
}
;################################################################################
																 buildPtn_Label()
;################################################################################
{
; Label
; 2024-08-06 AMB, ADDED
; WORK IN PROGRESS

	opt 		:= '(?i)'												; pattern options
	LC			:= '(?:' gnLineComment ')'								; line comment (allows lead ws to be consumed already)
	TG			:= '(?:' uniqueTag('\w++') ')'							; mask tags
	CT			:= '(?<CT>(?:\h*+(?>' LC '|' TG ')))'					; line-comment OR tag
	trail		:= '(?<trail>' . CT . '|\h*+(?=\v|$))'					; line-comment, tag, or end of line
;	declare		:= '^\h*+(?<name>[^;,\s``]+)(?<!:):(?!:)'				; label declaration
	declare		:= gPtn_LBLDecl											; label declaration
	pattern		:= opt . declare . trail
	return		pattern
}
;################################################################################
																buildPtn_HotKey()
;################################################################################
{
; hotkey.
; 2024-08-06 AMB, ADDED

	opt 	:= '(?i)'														; pattern options
	k01		:= '(?:[$~]?\*?)'												; special commands
	k02		:= '(?:[<>]?[!^+#]*+)*+'										; modifiers - short
	k03		:= '[a-z0-9]'													; alpha-numeric
	k04		:= "[.?)(\][}{$|+*^:\\'``-]"									; symbols 1 (regex special)
	k05		:= '(?:``;|[<>,"~!@#%&=_])'										; symbols 2
	k06		:= '(?:[lrm]?(?:alt|c(?:on)?tro?l|shift|win|button)(?:\h+up)?)'	; modifiers - long
	k07		:= 'numpad(?:\d|end|add)'										; numpad special
	k08		:= 'wheel(?:up|down)'											; mouse
	k09		:= '(?:f|joy)\d++'												; func keys or joystick button
	k10		:= '(?:(?:appskey|bkspc|(?:back)?space|del|delete|'				; named keys
			   . 'end|enter|esc(?:ape)?|home|pgdn|pgdn|pause|tab|'
			   . 'up|dn|down|left|right|(?:caps|scroll)lock)(?:\h+up)?)'
	repeat	:= '(?:\h++(?:&\h++)?(?-1))*'									; allow repeated keys
	pattern	:= opt '^(\s*+' k01 '(' k02 '(?:' k03 '|' k04 '|' k05 '|' k06
			. '|' k07 '|' k08 '|' k09 '|' k10 '))' . repeat . '::)' ;.*'
	return	pattern
}
;################################################################################
																   buildPtn_CLS()
;################################################################################
{
; CLASS-BLOCK pattern
; 2024-07-07 AMB, UPDATED comment needle to bypass escaped semicolon

	opt 		:= '(*UCP)(?im)'										; pattern options
	LC			:= '(?:' gnLineComment ')'								; line comment (allows lead ws to be consumed already)
	TG			:= '(?:' uniqueTag('\w++') ')'							; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*+'						; optional line comment OR tag
	TCT			:= '(?>\s*+' . CT . ')*+'								; optional trailing comment or tag (MUST BE ATOMIC)
	cName		:= '(?<cName>[_a-z]\w*+)'								; cName		- captures class name
	cExtends	:= '(?:(\h+EXTENDS\h+[_a-z]\w*+)?)'						; cExtends	- support extends keyword
	declare		:= '^\h*+\bCLASS\b\h++' . cName . cExtends				; declare	- class declaration
	brcBlk		:= '\s*+(?<brcBlk>\{(?<BBC>(?>[^{}]|\{(?&BBC)})*+)})'	; brcBlk	- braces block, BBC - block contents (allows multi-line span)
	pattern		:= opt . '(?<declare>' declare . TCT . ')' . brcBlk
	return		pattern
}
;################################################################################
																  buildPtn_FUNC()
;################################################################################
{
; FUNCTION-BLOCK pattern - supports class methods also
; 2024-07-07 AMB, UPDATED comment needle to bypass escaped semicolon

	opt 		:= '(*UCP)(?im)'										; pattern options
	LC			:= '(?:' gnLineComment ')'								; line comment (allows lead ws to be consumed already)
	TG			:= '(?:' uniqueTag('\w++') ')'							; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*+'						; optional line comment OR tag
	TCT			:= '(?>\s*+' . CT . ')*+'								; optional trailing comment or tag (MUST BE ATOMIC)
	exclude		:= '(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|'					; \K|		- added to prevent If/While/Loop from being captured
	fName		:= '(?<fName>[_a-z]\w*+)'								; fName		- captures function/method name
	fArgG		:= '(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)\))'	; fArgG		- argument group (in parenth), Args - indv args (allows multi-line span)
	declare		:= fName . fArgG . TCT									; declare	- function declaration
	brcBlk		:= '\s*+(?<brcBlk>\{(?<BBC>(?>[^{}]|\{(?&BBC)})*+)}))'	; brcBlk	- braces block, BBC - block contents (allows multi-line span)
	pattern		:= opt . '^\h*+(?:' . exclude . declare . brcBlk
	return		pattern
}
;################################################################################
																	buildPtn_IF()
;################################################################################
{
; IF block
; 2024-08-06 AMB, ADDED
; WORK IN PROGRESS

	opt 	:= '(*UCP)(?im)'													; pattern options
	noPth	:= '(?:.*+)'															; no parentheses
	noBB	:= noPth															; no braces block
	LC		:= '(?:' gnLineComment ')'											; line comment (allows lead ws to be consumed already)
	TG		:= '(?:' uniqueTag('\w++') ')'										; mask tags
	CT		:= '(?:' . LC . '|' . TG . ')*+'										; optional line comment OR tag
	TCT		:= '(?>\s*+' . CT . ')*+'												; optional trailing comment or tag (MUST BE ATOMIC)

	; IF portion
	ifPth	:= '(?<ifPth>(?:!*+\s*+)*\((?<ifPC>(?>[^()]|\((?&ifPC)\))*+)\))'	; ifPth		- (optional) parentheses, ifPC - parentheses contents (allows multi-line span)
	ifArg	:= '(?<ifArg>(?:\h*+' . ifPth . ')|(?:\h++' . noPth . '))' . TCT		; ifArg		- arguments (conditions and optional trailing comments/tags)
	ifBB	:= '(?<ifBB>\{(?<ifBBC>(?>[^{}]|\{(?&ifBBC)})*+)})'					; ifBB		- (optional) block with braces, ifBBC - brace block contents
	ifBlk	:= '(?<ifBlk>\s++(?:' . ifBB . '|' . noBB . '))'						; ifBlk		- block (either brace block or single line)
	ifStr	:= '(?<ifStr>\h*+\bIF\b' . ifArg . ifBlk . ')'						; ifStr		- IF block string
	ifBLCT	:= '(?<ifBLCT>' . TCT . ')'											; ifBLCT	- (optional) trailing blank lines, comments and tags
	; ELSEIF portion
	efPth	:= '(?<efPth>(?:!*+\s*+)*+\((?<efPC>(?>[^()]|\((?&efPC)\))*+)\))'		; efPth		- (optional) parentheses, efPC - parentheses contents (allows multi-line span)
	efArg	:= '(?<efArg>(?:\h*+' . efPth . ')|(?:\h++' . noPth . '))' . TCT		; efArg		- arguments (conditions and optional trailing comments/tags)
	efBB	:= '(?<efBB>\{(?<efBBC>(?>[^{}]|\{(?&efBBC)})*+)})'					; efBB		- (optional) blk w/braces (only captures last ELSEIF), efBBC - brace blk contents
	efBlk	:= '(?<efBlk>\s++(?:' . efBB . '|' . noBB . '))'						; efBlk		- block (either brace block or single line)
	efStr	:= '(?<efStr>\bELSE\h+IF\b' . efArg . efBlk . ')'					; efStr		- ELSEIF block string
	efBLCT	:= '(?<efBLCT>' . TCT . ')'											; efBLCT	- (optional) trailing blank lines, comments and tags
	; ELSE portion
	eBB		:= '(?<eBB>\{(?<eBBC>(?>[^{}]|\{(?&eBBC)})*+)})'				; eBB		- (optional) block with braces, eBBC - brace block contents
	eBlk	:= '(?<eBlk>\s++(?:(?:' . eBB . ')|(?:' . noBB . ')))'			; eBlk		- block (either brace block or single line)
	eStr	:= '(?<eStr>\s*+\bELSE\b' . eBLK . ')'							; eStr		- ELSE block string
;	pattern := opt . ifStr . ifBLCT . '(' . efStr . efBLCT . '|' . eStr . ')*'

;	A_Clipboard := pattern

	; 2024-? - simplified version - work in progress
	pattern := '(?im)^\h*+\bIF\b(?<all>(?>(?>\h*+(!?\((?>[^)(]++|(?-1))*+\))|[^;&|{\v]++|\s*+(?>and|or|&&|\|\|))++)(?<brc>\s*+\{(?>[^}{]++|(?-1))*+\}))((\s*+\bELSE IF\b(?&all))*+)((\s*+\bELSE\b(?&brc))*+)'
	return	pattern
}
