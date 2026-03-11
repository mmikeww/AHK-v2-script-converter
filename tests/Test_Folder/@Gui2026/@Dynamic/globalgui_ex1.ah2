; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
MyFunc() {
   If (!HasV2Gui("1")) {
      mV2Gui["1"] := NewV2Gui("1")
   }
   mV2Gui["1"].Add("Text",,"Gui")
   mV2Gui["1"].Show("w150")
}
MyFunc()

F1::
{ ; V1toV2: Added opening brace for [F1]
global ; V1toV2: Made function global
Try mV2Gui["1"].Destroy()
Return
} ; V1toV2: Added closing brace for [F1]