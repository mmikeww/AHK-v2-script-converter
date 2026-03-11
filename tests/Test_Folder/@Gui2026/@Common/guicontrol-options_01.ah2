; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","MyListbox"]] := mV2Gui["1"].Add("Listbox","vMyListbox")
mV2Gui["1"].Show()
mV2GC[["1","MyListbox"]].Opt("+AltSubmit")