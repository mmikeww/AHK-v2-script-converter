#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
MyFunc() {
   If (!HasV2Gui("")) {
      mV2Gui[""] := NewV2Gui("")
   }
   mV2Gui[""].Add("Text",,"Gui")
   mV2Gui[""].Show("w150")
}
MyFunc()

F1::
{ ; V1toV2: Added opening brace for [F1]
global ; V1toV2: Made function global
DestroyGui("")
Return
} ; V1toV2: Added closing brace for [F1]