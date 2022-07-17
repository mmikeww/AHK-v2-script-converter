#include <stdio.h>

#define NOGDI
#define WIN32_LEAN_AND_MEAN
#define NOCRYPT
#define NOSERVICE

#define NOATOM
#define NOGDICAPMASKS
#define NOMETAFILE
#define NOMINMAX
#define NOMSG
// #define NOOPENFILE
#define NORASTEROPS
#define NOSCROLL
#define NOSOUND
#define NOSYSMETRICS
#define NOTEXTMETRIC
#define NOWH
#define NOCOMM
#define NOKANJI
#define NOMCX


#include <windows.h>

typedef uintptr_t uptr_t;   // Define uptr_t, an unsigned integer type large enough to hold a pointer.
typedef intptr_t sptr_t;    // Define sptr_t, a signed integer large enough to hold a pointer.

typedef sptr_t (*SciFnDirect)(sptr_t ptr, unsigned int iMessage, uptr_t wParam, sptr_t lParam);
typedef sptr_t (*SciFnDirectStatus)(sptr_t ptr, unsigned int iMessage, uptr_t wParam, sptr_t lParam, int *pStatus);

typedef long Sci_PositionCR;

#define SCINT_NONE 0
#define SCINT_STRING1 1
#define SCINT_STRING2 2
#define SCINT_COMMENT1 3
#define SCINT_COMMENT2 4
#define SCINT_NUMBER 5
#define SCINT_BRACE 6
#define SCINT_PUNCT 7
#define SCINT_WORD 8
#define SCINT_SPACE 9

struct Sci_CharacterRange {
    Sci_PositionCR cpMin;
    Sci_PositionCR cpMax;
};

struct Sci_TextRange {
    struct Sci_CharacterRange chrg;
    char *lpstrText;
};

struct sci_ctl {
    HWND hwnd;
    int status;
} sci_ctl;

struct scint {
    unsigned int pos;
    unsigned int length;
    unsigned int linesAdded;
    int blank1; // for easier alignment
    
    char strStyle1; // 8 styles
    char strStyle2;
    char commentStyle1;
    char commentStyle2;
    char braceStyle;
    char braceBadStyle;
    char punctStyle;
    char numStyle;
    
    char *braces;
    char *comment1;
    char *comment2a;
    char *comment2b;
    char *escape;
    char *punct;
    char *string1;
    char *string2;
    char *wordChars;
} scint;

struct wordList {
    char kw1ID;
    char kw2ID;
    char kw3ID;
    char kw4ID;
    char kw5ID;
    char kw6ID;
    char kw7ID;
    char kw8ID;
    
    char *kwList1;
    char *kwList2;
    char *kwList3;
    char *kwList4;
    char *kwList5;
    char *kwList6;
    char *kwList7;
    char *kwList8;
} wordList;


SciFnDirect pSciMsg; // declare direct function
SciFnDirectStatus pSciMsgStat; // declare direct function

sptr_t directPtr = 0;
HWND scintHwnd = 0;


char * int_str(int iInput) {
    static char buf[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    return itoa(iInput, buf, 10);
}

char * hex_str(int iInput) {
    static char buf[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    return itoa(iInput, buf, 16);
}

// thanks to TutorialsPoint.com for making this easy to understand
// Link: https://www.tutorialspoint.com/cprogramming/c_variable_arguments.htm
//
// and thanks to robodesign on AHK forums for pointing out the OutputDebugStringA() func.
void dbg(int num, ...) {
    
    int i, total_sz = 5, offset = 5;
    
    va_list valist;
    char *outStr = calloc(1, sizeof(char)), *curStr = "";
    outStr = realloc(outStr, 6);
    memcpy(outStr, "AHK: ", 5);
    outStr[5] = '\0';
    
    /* initialize valist for num number of arguments */
    va_start(valist, num);
    
    for (i=0 ; i<num ; i++) {
        curStr = va_arg(valist, char *);
        total_sz += strlen(curStr);
        
        outStr = realloc(outStr, total_sz + 1);
        memcpy(outStr + offset, curStr, strlen(curStr));
        outStr[total_sz] = '\0';
        offset += strlen(curStr);
    }
    
    OutputDebugStringA(outStr);
    free(outStr);
}


// thanks to Andreas Storvik Strauman for this variable array code
// Link: https://stackoverflow.com/questions/30280444/array-of-unknown-number-of-elements-in-c
typedef struct {
    unsigned int size;
    unsigned int capacity;
    unsigned int *array;
} array_t;

#define ARRAY_INIT_CAPACITY 4

array_t *new_array(){
    array_t *arr=malloc(sizeof(array_t));
    arr->array=malloc(sizeof(int)*ARRAY_INIT_CAPACITY);
    arr->size=0;
    arr->capacity=ARRAY_INIT_CAPACITY;
    return arr;
}

void increase_array(array_t *array){
    int new_capacity=array->capacity*2;
    int *new_location = realloc(array->array, new_capacity*sizeof(int));
    if (!new_location) {
        fprintf(stderr, "Out of memory");
        exit(1);
    }
    array->capacity=new_capacity;
    array->array=new_location;
}

void array_append(array_t *array, int item){
    if (array->size >= array->capacity){
        increase_array(array);
    }
    array->array[array->size]=item;
    array->size+=1;
}

/*
Error Codes:

0 - no error


*/

// 2 chars = -64 thru -33
// 3 chars = -32 thru -17
// 4 chars = -16 thru -1
int char_len(char ch) {
    if (ch >= -64 && ch <= -33)
        return 2;
    else if (ch >= -32 && ch <= -17)
        return 3;
    else if (ch >= -16 && ch <= -1)
        return 4;
    else
        return 1;
}

sptr_t CallStatus(unsigned int iMessage, uptr_t wParam, sptr_t lParam) {    // DirectStatus func does not work :(
    int *pStatus;                                                           // causes error 0x00000005
    sptr_t result = pSciMsgStat(directPtr, iMessage, wParam, lParam, 0);
    sci_ctl.status = *pStatus;
    return result;
}

sptr_t Call(unsigned int iMessage, uptr_t wParam, sptr_t lParam) { // direct func works!
    return pSciMsg(directPtr, iMessage, wParam, lParam);;
}

// sptr_t Call(unsigned int iMessage, uptr_t wParam, sptr_t lParam) { // basic SendMessage() wrapper
    // return SendMessage(scintHwnd, iMessage, wParam, lParam);;
// }

__declspec(dllimport) sptr_t Init(HWND hwnd) {
    scintHwnd = hwnd; // global var, used with Call() wrapper func
    
    // It appears to work, but calling pSciMsgStat() always results in error 0x00000005.
    pSciMsgStat = (SciFnDirectStatus) SendMessage(scintHwnd, 0xAD4, 0, 0); // SCI_GETDIRECTSTATUSFUNCTION
    
    // This one works.
    pSciMsg = (SciFnDirect) SendMessage(scintHwnd, 0x888, 0, 0); // SCI_GETDIRECTFUNCTION
    
    directPtr = (sptr_t) SendMessage(scintHwnd, 0x889, 0, 0); // SCI_GETDIRECTPOINTER
    
    return directPtr;
};

unsigned int DelBrace(struct scint *data) { // BeforeDelete event (mostly), or right after commenting out a line
    
    unsigned int docLength = Call(0x7D6, 0, 0); // SCI_GETLENGTH // mostly for screen styling
    
    if (data->length == docLength)
        return 0;
    
    char buf[10];
    
    unsigned int mPos = 0, curPos = 0, style_check = 0;
    unsigned int startPos = data->pos;
    unsigned int endPos = startPos + data->length;
    
    unsigned int chunkLen  = endPos - startPos;
    
    char *curChar;
    
    struct Sci_CharacterRange cr;
    struct Sci_TextRange tr;
    
    cr.cpMin = startPos;
    cr.cpMax = endPos;
    tr.chrg = cr;
    tr.lpstrText = calloc(endPos-startPos+2, sizeof(char));
    
    Call(0x872, 0, (LPARAM) &tr); // SCI_GETTEXTRANGE
    // char *docTextRange = tr.lpstrText;
    // -----------------------------------------------------------------
    // char *docTextRange = (char *) Call(0xA53, startPos, endPos); // SCI_GETCHARACTERPOINTER (0x9D8) / SCI_GETRANGEPOINTER (0xA53)
    // -----------------------------------------------------------------
    
    for (int j=0 ; j<chunkLen ; j++) {
        
        curChar = &tr.lpstrText[j];
        curPos = startPos + j;
        
        if (curPos > (docLength-1))
            return 0;
        
        if (strchr(data->braces, *curChar)) {
        
            style_check = Call(0x7DA, curPos, 0); // SCI_GETSTYLEAT
            if (style_check != data->braceStyle) {
                
                continue;
            }
            
            mPos = Call(0x931, curPos, 0);
            if (mPos != -1) {
                Call(0x7F0, mPos, 0);                       // SCI_STARTSTYLING
                Call(0x7F1, 1, (LPARAM) data->braceBadStyle);  // SCI_SETSTYLING
                Call(0x7F0, curPos, 0);                     // SCI_STARTSTYLING
                Call(0x7F1, 1, (LPARAM) data->braceBadStyle);  // SCI_SETSTYLING
                
            }
            
            style_check = Call(0x7DA, docLength-1, 0); // SCI_GETSTYLEAT // reset last style pos checking
            Call(0x7F0, docLength-1, 0);    // SCI_STARTSTYLING
            Call(0x7F1, 1, (LPARAM) style_check);    // SCI_SETSTYLING
        }
    }
    
    free(tr.lpstrText);
    
    return 0;

}

__declspec(dllimport) unsigned int DeleteRoutine(struct scint *data) { // for calling DelBrace() from outside the DLL
    return DelBrace(data);
}

// keywords props:
// -> kw1ID .. kw8ID
// -> kwList1 .. kwList8

char match_kw(struct wordList *keywords, char *Word, int CaseSense) {
    
    if (!CaseSense) {
        for(int i=1 ; i < (strlen(Word)-1) ; i++) // convert to lowercase - need to do this dynamically
            Word[i] = tolower(Word[i]);
    }
    
    if (strstr(keywords->kwList1, Word))
            return keywords->kw1ID;
    
    if (strstr(keywords->kwList2, Word))
            return keywords->kw2ID;
    
    if (strstr(keywords->kwList3, Word))
            return keywords->kw3ID;
    
    if (strstr(keywords->kwList4, Word))
            return keywords->kw4ID;

    if (strstr(keywords->kwList5, Word))
            return keywords->kw5ID;
    
    if (strstr(keywords->kwList6, Word))
            return keywords->kw6ID;
    
    if (strstr(keywords->kwList7, Word))
            return keywords->kw7ID;
    
    if (strstr(keywords->kwList8, Word))
            return keywords->kw8ID;
    
    return 0;
}

__declspec(dllimport) unsigned int ChunkColoring(struct scint *data, int loading, struct wordList *keywords, int CaseSense) { // it's alive!
    
    unsigned int docLength = Call(0x7D6, 0, 0); // SCI_GETLENGTH // mostly for screen styling
    
    if (docLength == 0)
        return 0;
    
    if ((docLength > 1) && (Call(0x7DA, data->pos-1, 0) == data->commentStyle2)
        && (Call(0x7DA, data->pos+data->length, 0) == data->commentStyle2)) {
        
        Call(0x7F0, data->pos, 0);  // SCI_STARTSTYLING
        Call(0x7F1, data->length, (LPARAM) data->commentStyle2);  // SCI_SETSTYLING
        return 0;
    }
    
    unsigned int mPos = 0;
    
    array_t *braceList = new_array();
    
    unsigned int startPos = 0, endPos = 0, startLine = 0, diff = 0, lastLine = 0, lines = 0, charLen = 0, endLine = 0;
    
    startLine = Call(0x876, data->pos, 0); // SCI_LINEFROMPOSITION
    startPos  = Call(0x877, startLine, 0); // SCI_POSITIONFROMLINE
    endLine   = Call(0x876, data->pos + data->length, 0);
    endPos    = Call(0x877, endLine, 0) + Call(0x92E, endLine, 0);
    
    unsigned int chunkLen  = endPos - startPos;
    
    char *docTextRange = (char *) Call(0xA53, startPos, endPos); // SCI_GETCHARACTERPOINTER (0x9D8) / SCI_GETRANGEPOINTER (0xA53)
    
    mPos = 0;
    unsigned int style_st = 0, style_len = 0, style_check = 0, curPos = 0, curStyle = SCINT_NONE, x_count = 0, i = 0;
    
    char *style_type = "", *curChar = "", *prevChar = "", *prevChar2 = "", *nextChar = "", *curWord = calloc(1,1);
    char *com1       = data->comment1;
    char *com1_test  = calloc(1,sizeof(char));
    char *escChar    = data->escape;
    
    char *com2a      = data->comment2a;
    char *com2b      = data->comment2b;
    
    char *com2a_test = calloc(1,sizeof(char)); // Init /* block comment */ match ...
    char *com2b_test = calloc(1,sizeof(char)); // and prepare for look ahead match.
    
    for (int j=0 ; j<chunkLen ; j++) {
        
        curChar = &docTextRange[j];
        curPos = startPos + j;
        
        // charLen = char_len(curChar[0]);
        
        // if (charLen > 1) {
            // j = j + (charLen - 1);
            // continue;
        // }
        
        if (curPos > (docLength-1))
            return 0;
        
        if (loading == 0) {
            style_check = Call(0x7DA, curPos, 0); // SCI_GETSTYLEAT
            if (style_check == data->commentStyle2)
                continue;
        }
        
        switch (curStyle) {
            
            case (SCINT_STRING1):
                
                prevChar = &docTextRange[j-1];
                prevChar2 = &docTextRange[j-2];
                
                if (*curChar != '"' || (*prevChar == *escChar && *prevChar2 != *escChar))
                    continue;
                
                Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle1);  // SCI_SETSTYLING
                curStyle = SCINT_NONE, style_st = 0;
                    
                break;
                
            case (SCINT_STRING2):
                
                prevChar = &docTextRange[j-1];
                prevChar2 = &docTextRange[j-2];
                
                if (*curChar != '\'' || (*prevChar == *escChar && *prevChar2 != *escChar))
                    continue;
                
                Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle2);  // SCI_SETSTYLING
                curStyle = SCINT_NONE, style_st = 0;
                    
                break;
                
            case (SCINT_COMMENT1):
                
                if (*curChar == '\n' || curPos == (docLength-1)) {
                    if (loading == 0) { // do NOT do this when loading the document, unnecessary and slow
                        data->length = chunkLen;
                        DelBrace(data);
                    }
                    
                    Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                    Call(0x7F1, (curPos-style_st+1), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                    curStyle = SCINT_NONE, style_st = 0;
                    
                }
                break;
                
            case (SCINT_COMMENT2):
            
                free(com2b_test); // block comment end
                com2b_test = calloc(strlen(com2b)+1, sizeof(char));
                strncpy(com2b_test, docTextRange+j, strlen(com2b));
                
                if (!strcmp(com2b, com2b_test)) {
                    Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                    Call(0x7F1, (curPos-style_st+strlen(com2b)), (LPARAM) data->commentStyle2);  // SCI_SETSTYLING
                    j = j + strlen(com2b) - 1;
                    curStyle = SCINT_NONE, style_st = 0;
                    
                }
                
                break;
                
            case (SCINT_NUMBER):
                
                i++;
                nextChar = (j < (chunkLen-1)) ? &docTextRange[j+1] : "";
                
                if (*curChar != 'x' && !isxdigit(*curChar)) {
                    Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                    Call(0x7F1, (curPos-style_st+1), (LPARAM) 32);  // SCI_SETSTYLING
                    style_st = 0, i = 0, curStyle = SCINT_NONE, x_count = 0;
                    continue;
                    
                } else if (*curChar == 'x') {
                    x_count++;
                    if (x_count > 1 || i != 2) {
                        Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                        Call(0x7F1, (curPos-style_st+1), (LPARAM) 32);  // SCI_SETSTYLING
                        style_st = 0, i = 0, curStyle = SCINT_NONE, x_count = 0;

                    }
                    continue;
                
                } else if (isspace(*nextChar) || ispunct(*nextChar) || curPos == (chunkLen-1)) {
                    Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                    Call(0x7F1, (curPos-style_st+1), (LPARAM) data->numStyle);  // SCI_SETSTYLING
                    style_st = 0, i = 0, curStyle = SCINT_NONE, x_count = 0;
                    
                }
                
                i++;
                break;
            
            case (SCINT_WORD):
                
                nextChar = (j < (chunkLen-1)) ? &docTextRange[j+1] : "";
                
                if (!strchr(data->wordChars, *nextChar) && !isdigit(*nextChar)) {
                    
                    int wordLen = curPos-style_st+1;
                    
                    curWord = realloc(curWord, wordLen + 3);
                    memcpy(curWord+1, &docTextRange[j-wordLen+1], wordLen);
                    curWord[0] = ' ';
                    curWord[wordLen+1] = ' ';
                    curWord[wordLen+2] = '\0';
                    int word_style = match_kw(keywords, curWord, CaseSense);
                    
                    if (word_style) {
                        Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                        Call(0x7F1, (wordLen), (LPARAM) word_style);  // SCI_SETSTYLING
                    }
                    else if (loading == 0) {
                        Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                        Call(0x7F1, (wordLen), (LPARAM) 32);  // SCI_SETSTYLING - default style
                    }
                    
                    curStyle = SCINT_NONE, style_st = 0, word_style = 0;
                }
                
                break;
            
            case (SCINT_SPACE):
                
                nextChar = (j < (chunkLen-1)) ? &docTextRange[j+1] : "";
                if (!isspace(*nextChar)) {
                    if (loading == 0) {
                        Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                        Call(0x7F1, (curPos-style_st+1), (LPARAM) 32);  // SCI_SETSTYLING - default style
                    }
                    curStyle = SCINT_NONE, style_st = 0;
                }
                
                break;
                
            case (SCINT_NONE):
                
                free(com1_test); // line comments
                com1_test = calloc(strlen(com1)+1, sizeof(char));
                strncpy(com1_test, docTextRange+j, strlen(com1));
                
                free(com2a_test); // block comment beginning
                com2a_test = calloc(strlen(com2a)+1, sizeof(char));
                strncpy(com2a_test, docTextRange+j, strlen(com2a));
                
                if (*curChar == '"') {
                    
                    curStyle = SCINT_STRING1, style_st = curPos;
                    
                } else if (*curChar == '\'') {
                    
                    curStyle = SCINT_STRING2, style_st = curPos;
                
                } else if (!strcmp(com1, com1_test)) {
                    
                    if (curPos == (docLength-1)) {
                        Call(0x7F0, (curPos), 0);  // SCI_STARTSTYLING
                        Call(0x7F1, strlen(com1), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                        continue;
                    }
                    
                    curStyle = SCINT_COMMENT1, style_st = curPos;
                
                } else if (!strcmp(com2a, com2a_test)) {
                    curStyle = SCINT_COMMENT2, style_st = curPos;
                
                } else if (isdigit(*curChar)) {
                    
                    nextChar = (j < (chunkLen-1)) ? &docTextRange[j+1] : "";
                    prevChar = (j > 0) ? &docTextRange[j-1] : "";
                    
                    if (isspace(*prevChar) || ispunct(*prevChar) || curPos == 0) {
                        
                        if (isspace(*nextChar) || ispunct(*nextChar) || curPos == (chunkLen-1)) {
                            Call(0x7F0, (curPos), 0);  // SCI_STARTSTYLING
                            Call(0x7F1, 1, (LPARAM) data->numStyle);  // SCI_SETSTYLING
                            curStyle = SCINT_NONE, style_st = 0, i = 0, x_count = 0;
                            
                        } else if (*nextChar == 'x' || isdigit(*nextChar)) {
                            curStyle = SCINT_NUMBER, style_st = curPos, i = 1, x_count = 0;
                            
                        }
                        
                    }
                    
                }
                else if (strchr(data->braces, *curChar)) {
                    
                    style_check = Call(0x7DA, curPos, 0); // SCI_GETSTYLEAT
                    if (style_check == data->braceStyle)
                        continue;
                    
                    array_append(braceList, curPos);
                    Call(0x7F0, (curPos), 0);  // SCI_STARTSTYLING
                    Call(0x7F1, 1, (LPARAM) data->braceBadStyle);  // SCI_SETSTYLING
                    
                }
                else if (strchr(data->punct, *curChar)) {
                    
                    Call(0x7F0, (curPos), 0);  // SCI_STARTSTYLING
                    Call(0x7F1, 1, (LPARAM) data->punctStyle);  // SCI_SETSTYLING
                    
                    curStyle = SCINT_NONE, style_st = 0;
                    
                }
                else if (strchr(data->wordChars, *curChar)) {
                    
                    nextChar = (j < (chunkLen-1)) ? &docTextRange[j+1] : "";
                    
                    if (!strchr(data->wordChars, *nextChar) && !isdigit(*nextChar)) {
                    
                        if (loading == 0) {
                            Call(0x7F0, curPos, 0);  // SCI_STARTSTYLING
                            Call(0x7F1, 1, (LPARAM) 32);  // SCI_SETSTYLING - default style
                        }
                        curStyle = SCINT_NONE, style_st = 0;
                    } else
                        curStyle = SCINT_WORD, style_st = curPos;
                    
                }
                else if (isspace(*curChar)) {
                    
                    nextChar = (j < (chunkLen-1)) ? &docTextRange[j+1] : "";
                    if (!isspace(*nextChar)) {
                        if (loading == 0) {
                            Call(0x7F0, curPos, 0);  // SCI_STARTSTYLING
                            Call(0x7F1, 1, (LPARAM) 32);  // SCI_SETSTYLING - default style
                        }
                        curStyle = SCINT_NONE, style_st = 0;
                    } else
                        curStyle = SCINT_SPACE, style_st = curPos;
                    
                }
                break;
                
        } // switch statement
        
        
        
    } // for loop
    
    style_check = Call(0x7DA, docLength-1, 0); // SCI_GETSTYLEAT // reset last style pos checking - required for properly matching braces
    Call(0x7F0, docLength-1, 0);    // SCI_STARTSTYLING
    Call(0x7F1, 1, (LPARAM) style_check);    // SCI_SETSTYLING
    
    unsigned int k = braceList->size;
    i = 0;
    while (i < k) {
        
        curPos = braceList->array[i];
        mPos = Call(0x931, curPos, 0);

        if (mPos != -1) {
            style_check = Call(0x7DA, curPos, 0); // SCI_GETSTYLEAT
            if (style_check != data->braceBadStyle) {
                i++;
                continue;
            }
            
            Call(0x7F0, mPos, 0);                       // SCI_STARTSTYLING
            Call(0x7F1, 1, (LPARAM) data->braceStyle);  // SCI_SETSTYLING
            Call(0x7F0, curPos, 0);                     // SCI_STARTSTYLING
            Call(0x7F1, 1, (LPARAM) data->braceStyle);  // SCI_SETSTYLING
            
            style_check = Call(0x7DA, docLength-1, 0);  // SCI_GETSTYLEAT // reset last style pos checking
            Call(0x7F0, docLength-1, 0);                // SCI_STARTSTYLING
            Call(0x7F1, 1, (LPARAM) style_check);       // SCI_SETSTYLING
            
        }
        
        i++;
    }
    
    free(curWord);
    
    free(braceList->array);
    free(braceList);
    
    if (com1_test)
        free(com1_test);
    if (com2a_test)
        free(com2a_test);
    if (com2b_test)
        free(com2b_test);
    
    return 0;
};


























