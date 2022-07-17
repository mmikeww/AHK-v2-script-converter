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

#define STYLE_NONE 0
#define STYLE_STRING1 1
#define STYLE_STRING2 2
#define STYLE_COMMENT1 3
#define STYLE_COMMENT2 4


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
    int pos;
    int length;
    int line;
    int linesAdded;
    
    char strStyle1; // 7 styles
    char strStyle2;
    char commentStyle1;
    char braceStyle;
    char braceBadStyle;
    char punctStyle;
    char numStyle;
    char operType; // 0 = full range // 1 = screen range
    
    char *braces;
    char *comment1;
    char *comment2a;
    char *comment2b;
    char *escape;
    HWND hwnd;
} scint;


SciFnDirect pSciMsg; // declare direct function
SciFnDirectStatus pSciMsgStat; // declare direct function

sptr_t directPtr = 0;
HWND scintHwnd = 0;

sptr_t CallStatus(unsigned int iMessage, uptr_t wParam, sptr_t lParam) {    // DirectStatus func does not work :(
    int *pStatus;                                                           // causes error 0x00000005
    sptr_t result = pSciMsgStat(directPtr, iMessage, wParam, lParam, 0);
    sci_ctl.status = *pStatus;
    return result;
}

sptr_t Call(unsigned int iMessage, uptr_t wParam, sptr_t lParam) { // direct func works!
    return pSciMsg(directPtr, iMessage, wParam, lParam);;
}

__declspec(dllimport) sptr_t Init(struct sci_ctl *data) {
    scintHwnd = data->hwnd;
    
    // It appears to work, but calling pSciMsgStat() always results in error 0x00000005.
    pSciMsgStat = (SciFnDirectStatus) SendMessage(scintHwnd, 0xAD4, 0, 0); // SCI_GETDIRECTSTATUSFUNCTION
    
    // This one works.
    pSciMsg = (SciFnDirect) SendMessage(scintHwnd, 0x888, 0, 0); // SCI_GETDIRECTFUNCTION
    
    directPtr = (sptr_t) SendMessage(scintHwnd, 0x889, 0, 0); // SCI_GETDIRECTPOINTER
    
    return directPtr;
};









__declspec(dllimport) unsigned int ChunkColoring(struct scint *data) { // experimenting
    
    unsigned int lastDocPos = Call(0x7D6, 0, 0); // SCI_GETLENGTH // mostly for screen styling
    unsigned int startPos = 0, endPos = 0, startLine = 0, diff = 0, lastLine = 0, lines = 0;
    
    if (data->operType == 0) { // full chunk styling
    
        startLine = Call(0x876, data->pos, 0); // SCI_LINEFROMPOSITION
        startPos  = Call(0x877, startLine, 0); // SCI_POSITIONFROMLINE
        
        diff      = data->pos - startPos;
        endPos    = startPos + data->length + diff;
        
    } else if (data->operType == 1) { // screen styling
    
        startLine  = Call(0x868, 0, 0); // SCI_GETFIRSTVISIBLELINE
        startLine  = Call(0x8AD, startLine, 0); // SCI_DOCLINEFROMVISIBLE
        lines      = Call(0x942, 0, 0); // SCI_LINESONSCREEN
        lastLine   = startLine + lines + 1;
        
        startPos  = Call(0x877, startLine, 0); // SCI_POSITIONFROMLINE
        endPos    = Call(0x877, lastLine, 0) + Call(0x92E, lastLine, 0); // SCI_POSITIONFROMLINE + SCI_LINELENGTH

    } else if (data->operType == 2) { // line styling
        
    }
    
    unsigned int chunkLen  = endPos - startPos;
    char *docTextRange = (char *) Call(0xA53, startPos, endPos); // SCI_GETCHARACTERPOINTER (0x9D8) / SCI_GETRANGEPOINTER (0xA53)
    
    unsigned int style_st = 0, style_check = 0, curPos = 0, mPos = 0;
    
    char *style_type = "";
    char *curChar = "", *prevChar = "";
    char *com1    = data->comment1;
    char *com1_test = calloc(1,sizeof(char));
    char *escChar = data->escape;
    char *com2a   = data->comment2a;
    char *com2b   = data->comment2b;
    char *com2a_test = calloc(1,sizeof(char));
    char *com2b_test = calloc(1,sizeof(char));
    
    for (int j=0 ; j<chunkLen ; j++) {
        curChar = &docTextRange[j];
        curPos = startPos + j;
        
        free(com1_test); // line comments
        com1_test = calloc(strlen(com1)+1, sizeof(char));
        strncpy(com1_test, docTextRange+j, strlen(com1));
        
        free(com2a_test); // block comment beginning
        com2a_test = calloc(strlen(com2a)+1, sizeof(char));
        strncpy(com2a_test, docTextRange+j, strlen(com2a));
        
        free(com2b_test); // block comment end
        com2b_test = calloc(strlen(com2b)+1, sizeof(char));
        strncpy(com2b_test, docTextRange+j, strlen(com2b));
        
        if (strlen(style_type)) {
            
            if (*curChar == '"' && style_type == "string1") {
                prevChar = &docTextRange[j-1];
                if (*prevChar == *escChar)
                    continue;
                
                Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle1);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                continue;
                
            } else if (*curChar == '\'' && style_type == "string2") {
                prevChar = &docTextRange[j-1];
                if (*prevChar == *escChar)
                    continue;
                
                Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle2);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                continue;
            
            } else if (*curChar == '\n' && style_type == "comment1") {
                Call(0x7F0, style_st, 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                continue;
                
            } else if (!strcmp(com2b, com2b_test)) {
                
                Call(0x7F0, style_st, 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+strlen(com2b)), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                
                continue;
                
            } else {
                continue;
            
            }
        }
        
        
        
        if (!strcmp(com1, com1_test)) {
            style_type = "comment1", style_st = curPos;
            
        } else if (*curChar == '"') {
            style_type = "string1", style_st = curPos;
            
        } else if (*curChar == '\'') {
            style_type = "string2", style_st = curPos;
            
        } else if (!strcmp(com2a, com2a_test)) {
            style_type = "comment_block", style_st = curPos;
        
        }
    }
    
    free(com1_test);
    free(com2a_test);
    free(com2b_test);
    
    return 7654;
};

__declspec(dllimport) unsigned int ScreenStyling(struct scint *data) {
    
    unsigned int lastDocPos = Call(0x7D6, 0, 0); // SCI_GETLENGTH
    
    unsigned int startLine  = Call(0x868, 0, 0); // SCI_GETFIRSTVISIBLELINE
                 startLine  = Call(0x8AD, startLine, 0); // SCI_DOCLINEFROMVISIBLE
    unsigned int lines      = Call(0x942, 0, 0); // SCI_LINESONSCREEN
    unsigned int lastLine   = startLine + lines + 1;
    
    unsigned int startPos  = Call(0x877, startLine, 0); // SCI_POSITIONFROMLINE
    unsigned int endPos    = Call(0x877, lastLine, 0) + Call(0x92E, lastLine, 0); // SCI_POSITIONFROMLINE + SCI_LINELENGTH
    unsigned int chunkLen  = endPos - startPos;
    
    char *docTextRange = (char *) Call(0xA53, startPos, endPos); // SCI_GETCHARACTERPOINTER (0x9D8) / SCI_GETRANGEPOINTER (0xA53)
    
    unsigned int style_st = 0, style_check = 0, curPos = 0, mPos = 0;
    
    char *style_type = "";
    char *curChar = "", *prevChar = "";
    char *comChar = data->comment1;
    char *escChar = data->escape;
    char *com2a   = data->comment2a;
    char *com2b   = data->comment2b;
    
    for (int j=0 ; j<chunkLen ; j++) {
        curPos = startPos + j;
        
        if (curPos > lastDocPos)
            return 4321;
        
        curChar = &docTextRange[j];
        
        if (strlen(style_type)) {
            if (*curChar == '"' && style_type == "string1") {
                prevChar = &docTextRange[j-1];
                if (*prevChar == *escChar)
                    continue;
                
                Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle1);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                continue;
                
            } else if (*curChar == '\'' && style_type == "string2") {
                prevChar = &docTextRange[j-1];
                if (*prevChar == *escChar)
                    continue;
                
                Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle2);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                continue;
            
            } else if (*curChar == '\n' && style_type == "comment1") {
                Call(0x7F0, style_st, 0);  // SCI_STARTSTYLING
                Call(0x7F1, (curPos-style_st+1), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                style_type = "", style_st = 0;
                
            } else {
                continue;
            
            }
        }
        
        if (*curChar == *comChar) {
            style_type = "comment1", style_st = curPos;
            
        } else if (*curChar == '"') {
            style_type = "string1", style_st = curPos;
            
        } else if (*curChar == '\'') {
            style_type = "string2", style_st = curPos;
            
        } 
        else if (strchr(data->braces, *curChar)) {
            style_check = Call(0x7DA, curPos, 0); // SCI_GETSTYLEAT
            
            if (style_check == data->braceStyle)
                continue;
            
            mPos = Call(0x931, curPos, 0);
            if (mPos != -1) {
                Call(0x7F0, mPos, 0);                       // SCI_STARTSTYLING
                Call(0x7F1, 1, (LPARAM) data->braceStyle);  // SCI_SETSTYLING
                Call(0x7F0, curPos, 0);                     // SCI_STARTSTYLING
                Call(0x7F1, 1, (LPARAM) data->braceStyle);  // SCI_SETSTYLING
            }
        }
    }
}









// __declspec(dllimport) unsigned int ChunkColoring(struct scint *data) { // experimenting
    // unsigned int startLine = Call(0x876, data->pos, 0); // SCI_LINEFROMPOSITION
    // unsigned int startPos  = Call(0x877, startLine, 0); // SCI_POSITIONFROMLINE
    
    // unsigned int diff      = data->pos - startPos;
    // unsigned int endPos    = startPos + data->length + diff;
    // unsigned int chunkLen  = endPos - startPos;
    
    // char *docTextRange = (char *) Call(0xA53, startPos, endPos); // SCI_GETCHARACTERPOINTER (0x9D8) / SCI_GETRANGEPOINTER (0xA53)
    
    // unsigned int style_st = 0, style_check = 0, curPos = 0, mPos = 0;
    
    // char *style_type = "";
    // char *curChar = "", *prevChar = "", *nextChar = "";
    // char *comChar = data->comment1;
    // char *escChar = data->escape;
    // char *com2a   = data->comment2a;
    // char *com2b   = data->comment2b;
    // char *com2a_test = calloc(1,sizeof(char));
    // char *com2b_test = calloc(1,sizeof(char));
    
    // for (int j=0 ; j<chunkLen ; j++) {
        // curChar = &docTextRange[j];
        // curPos = startPos + j;
        
        // free(com2a_test);
        // com2a_test = calloc(strlen(com2a)+1, sizeof(char));
        // strncpy(com2a_test, docTextRange+j, strlen(com2a));
        
        // free(com2b_test);
        // com2b_test = calloc(strlen(com2b)+1, sizeof(char));
        // strncpy(com2b_test, docTextRange+j, strlen(com2b));
        
        // if (strlen(style_type)) {
            
            // if (*curChar == '"' && style_type == "string1") {
                // prevChar = &docTextRange[j-1];
                // if (*prevChar == *escChar)
                    // continue;
                
                // Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle1);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                // continue;
                
            // } else if (*curChar == '\'' && style_type == "string2") {
                // prevChar = &docTextRange[j-1];
                // if (*prevChar == *escChar)
                    // continue;
                
                // Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle2);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                // continue;
            
            // } else if (*curChar == '\n' && style_type == "comment1") {
                // Call(0x7F0, style_st, 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+1), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                // continue;
                
            // } else if (!strcmp(com2b, com2b_test)) {
                
                // Call(0x7F0, style_st, 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+strlen(com2b)), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                
                // continue;
                
            // } else {
                // continue;
            
            // }
        // }
        
        
        // if (*curChar == *comChar) {
            // style_type = "comment1", style_st = curPos;
            
        // } else if (*curChar == '"') {
            // style_type = "string1", style_st = curPos;
            
        // } else if (*curChar == '\'') {
            // style_type = "string2", style_st = curPos;
            
        // } else if (!strcmp(com2a, com2a_test)) {
            // style_type = "comment_block", style_st = curPos;
        
        // }
    // }
    
    // return 7654;
// };

// __declspec(dllimport) unsigned int ScreenStyling(struct scint *data) {
    
    // unsigned int lastDocPos = Call(0x7D6, 0, 0); // SCI_GETLENGTH
    
    // unsigned int startLine  = Call(0x868, 0, 0); // SCI_GETFIRSTVISIBLELINE
                 // startLine  = Call(0x8AD, startLine, 0); // SCI_DOCLINEFROMVISIBLE
    // unsigned int lines      = Call(0x942, 0, 0); // SCI_LINESONSCREEN
    // unsigned int lastLine   = startLine + lines + 1;
    
    // unsigned int startPos  = Call(0x877, startLine, 0); // SCI_POSITIONFROMLINE
    // unsigned int endPos    = Call(0x877, lastLine, 0) + Call(0x92E, lastLine, 0); // SCI_POSITIONFROMLINE + SCI_LINELENGTH
    // unsigned int chunkLen  = endPos - startPos;
    
    // char *docTextRange = (char *) Call(0xA53, startPos, endPos); // SCI_GETCHARACTERPOINTER (0x9D8) / SCI_GETRANGEPOINTER (0xA53)
    
    // unsigned int style_st = 0, style_check = 0, curPos = 0, mPos = 0;
    
    // char *style_type = "";
    // char *curChar = "", *prevChar = "";
    // char *comChar = data->comment1;
    // char *escChar = data->escape;
    // char *com2a   = data->comment2a;
    // char *com2b   = data->comment2b;
    
    // for (int j=0 ; j<chunkLen ; j++) {
        // curPos = startPos + j;
        
        // if (curPos > lastDocPos)
            // return 4321;
        
        // curChar = &docTextRange[j];
        
        // if (strlen(style_type)) {
            // if (*curChar == '"' && style_type == "string1") {
                // prevChar = &docTextRange[j-1];
                // if (*prevChar == *escChar)
                    // continue;
                
                // Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle1);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                // continue;
                
            // } else if (*curChar == '\'' && style_type == "string2") {
                // prevChar = &docTextRange[j-1];
                // if (*prevChar == *escChar)
                    // continue;
                
                // Call(0x7F0, (style_st), 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+1), (LPARAM) data->strStyle2);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                // continue;
            
            // } else if (*curChar == '\n' && style_type == "comment1") {
                // Call(0x7F0, style_st, 0);  // SCI_STARTSTYLING
                // Call(0x7F1, (curPos-style_st+1), (LPARAM) data->commentStyle1);  // SCI_SETSTYLING
                // style_type = "", style_st = 0;
                
            // } else {
                // continue;
            
            // }
        // }
        
        // if (*curChar == *comChar) {
            // style_type = "comment1", style_st = curPos;
            
        // } else if (*curChar == '"') {
            // style_type = "string1", style_st = curPos;
            
        // } else if (*curChar == '\'') {
            // style_type = "string2", style_st = curPos;
            
        // } 
        // else if (strchr(data->braces, *curChar)) {
            // style_check = Call(0x7DA, curPos, 0); // SCI_GETSTYLEAT
            
            // if (style_check == data->braceStyle)
                // continue;
            
            // mPos = Call(0x931, curPos, 0);
            // if (mPos != -1) {
                // Call(0x7F0, mPos, 0);                       // SCI_STARTSTYLING
                // Call(0x7F1, 1, (LPARAM) data->braceStyle);  // SCI_SETSTYLING
                // Call(0x7F0, curPos, 0);                     // SCI_STARTSTYLING
                // Call(0x7F1, 1, (LPARAM) data->braceStyle);  // SCI_SETSTYLING
            // }
        // }
    // }
// }
































