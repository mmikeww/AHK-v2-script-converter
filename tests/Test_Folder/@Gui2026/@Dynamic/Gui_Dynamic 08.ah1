
global ColorList := ["000000","7F7F7F","880015","ED1C24","FF7F27","FFF200","22B14C","00A2E8","3F48CC","A349A4","FFFFFF","C3C3C3","B97A57","FFAEC9","FFC90E","EFE4B0","B5E61D","99D9EA","7092BE","C8BFE7"]
global ALED,Thickness

ft := 0
if(1) { ;showgui:=!showgui){
  if(!ft){
    ft:=1
    Gui,99:+AlwaysOnTop +ToolWindow
    Gui,99:Color,% ColorList[1] ;, 333333
    Gui,99:Font, s8 ,Segoe UI
    y:=0,x:=m:=20,w:=m,C:="00ffff"
    Gui,99:Margin,20,20
    Loop,% ColorList.Length()  {
      if(A_Index=11)
        x:=m+w,y:=0
      y+=m
      Gui,99:Add,Text,% "x" x " y" y " w" m " h" m " hwndf_hwnd gChangeColor" " vc1_" a_index, x
      Gui,99:Add,Progress,% "x" x " y" y " w" m " h" m " c" ColorList[A_Index] " Background" C " hwndb_hwnd" " vc2_" a_index  ,100
      C:="555555"
    }
    Gui,99:Add,Edit,xm y+1 w40 r1 Limit2 Center hwndALED gChangeBrush,98
    Gui,99:Add,Edit,xm y+1 w40 r1 Limit2 Center hwndThickness gChangeBrush,1
    Gui,99:Add,button,xm y+2 w40 vapply ghandle_apply, APPLY
    GuiControl,% "99:Focus", apply
  }
  Gui,99:Show,% "x" (A_ScreenWidth//2)+150 " y" (A_ScreenHeight//2)-200,Color
}

msgbox click a color in the palette

return
ChangeColor:
ci := RegExReplace(A_GuiControl, "^.+_(\d+)$", "$1")
MsgBox % "color index := " ci "`ncolor value := [" ColorList[ci] "]"
return

ChangeBrush:
MsgBox % "[" "Change Brush to " A_GuiControl "]"
return

handle_apply:
MsgBox % "[" "Apply" "]"
return