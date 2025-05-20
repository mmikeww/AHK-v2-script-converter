/**
 * Credits: Coco & Lexikos
 * References:
 *     http://ahkscript.org/boards/viewtopic.php?f=5&t=5487&p=31581#p31581
 *     http://msdn.microsoft.com/en-us/library/ms693360
 */
WB_onKey(wParam, lParam, nMsg, hWnd)
{
   WinClass := WinGetClass("ahk_id " hWnd)
   if (WinClass == "Internet Explorer_Server")
   {
      static riid_IDispatch
      if !VarSetStrCapacity(&riid_IDispatch)
      {
         VarSetStrCapacity(&riid_IDispatch, 16)
         DllCall("ole32\CLSIDFromString", "WStr", "{00020400-0000-0000-C000-000000000046}", "Ptr", StrPtr(riid_IDispatch))
      }
      pacc := 0
      DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", 0xFFFFFFFC, "Ptr", StrPtr(riid_IDispatch), "Ptr*", &pacc) ; OBJID_CLIENT:=0xFFFFFFFC
     
      static IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"
      pwin := ComObjQuery(pacc, IID_IHTMLWindow2, IID_IHTMLWindow2)
         ObjRelease(pacc)
     
      static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
           , SID_SWebBrowserApp := IID_IWebBrowserApp
      pweb := ComObjQuery(pwin, SID_SWebBrowserApp, IID_IWebBrowserApp)
         ; ObjRelease(pwin)
      wb := ComValue(9, pweb, 1)

      static IID_IOleInPlaceActiveObject := "{00000117-0000-0000-C000-000000000046}"
      pIOIPAO := ComObjQuery(wb, IID_IOleInPlaceActiveObject)
      
      MouseGetPos(&A_GuiX, &A_GuiY)
      MSG := Buffer(48, 0)                      ; http://goo.gl/GX6GNm
      NumPut("UPtr", hWnd, 
      "UPtr", nMsg, 
      "UPtr", wParam, 
      "UPtr", lParam, 
      "UInt", A_EventInfo, 
      "Int", A_GuiX, 
      "Int", A_GuiY, 
      MSG) ; hwnd

      TranslateAccelerator := NumGet(NumGet(pIOIPAO.Ptr + 0, "UPtr") + 5*A_PtrSize, "UPtr")
      Loop 2
         r := DllCall(TranslateAccelerator, "Ptr", pIOIPAO, "Ptr", MSG.Ptr)
      until (wParam != 9 || wb.Document.activeElement != "")
      ; ObjRelease(pIOIPAO)
      if (r == 0)
         return 0
   }
}