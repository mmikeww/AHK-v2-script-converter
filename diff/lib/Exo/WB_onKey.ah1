/**
 * Credits: Coco & Lexikos
 * References:
 *     http://ahkscript.org/boards/viewtopic.php?f=5&t=5487&p=31581#p31581
 *     http://msdn.microsoft.com/en-us/library/ms693360
 */
WB_onKey(wParam, lParam, nMsg, hWnd)
{
   WinGetClass WinClass, ahk_id %hWnd%
   if (WinClass == "Internet Explorer_Server")
   {
      static riid_IDispatch
      if !VarSetCapacity(riid_IDispatch)
      {
         VarSetCapacity(riid_IDispatch, 16)
         DllCall("ole32\CLSIDFromString", "WStr", "{00020400-0000-0000-C000-000000000046}", "Ptr", &riid_IDispatch)
      }
      DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", 0xFFFFFFFC, "Ptr", &riid_IDispatch, "Ptr*", pacc) ; OBJID_CLIENT:=0xFFFFFFFC
     
      static IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"
      pwin := ComObjQuery(pacc, IID_IHTMLWindow2, IID_IHTMLWindow2)
         ObjRelease(pacc)
     
      static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
           , SID_SWebBrowserApp := IID_IWebBrowserApp
      pweb := ComObjQuery(pwin, SID_SWebBrowserApp, IID_IWebBrowserApp)
         ObjRelease(pwin)
      wb := ComObject(9, pweb, 1)

      static IID_IOleInPlaceActiveObject := "{00000117-0000-0000-C000-000000000046}"
      pIOIPAO := ComObjQuery(wb, IID_IOleInPlaceActiveObject)

      VarSetCapacity(MSG, 48, 0)                      ; http://goo.gl/GX6GNm
      , NumPut(A_GuiY                                 ; POINT.y
      , NumPut(A_GuiX                                 ; POINT.x
      , NumPut(A_EventInfo                            ; time
      , NumPut(lParam                                 ; lParam
      , NumPut(wParam                                 ; wParam
      , NumPut(nMsg                                   ; message
      , NumPut(hWnd, MSG)))), "UInt"), "Int"), "Int") ; hwnd

      TranslateAccelerator := NumGet(NumGet(pIOIPAO + 0) + 5*A_PtrSize)
      Loop 2
         r := DllCall(TranslateAccelerator, "Ptr", pIOIPAO, "Ptr", &MSG)
      until (wParam != 9 || wb.Document.activeElement != "")
      ObjRelease(pIOIPAO)
      if (r == 0)
         return 0
   }
}