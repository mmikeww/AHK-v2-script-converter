#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder

; fixes for truncation and false positives

fcV2GC("","MyLV").move(400, 50, 20) ; V1toV2: Verify that control [MyLV] is accurate

fcV2GC("","MyLV").move(, , width, height)  ; width/height no longer truncated ; V1toV2: Verify that control [MyLV] is accurate

fcV2GC("","MyLV").move(, , halfWidth)  ; halfWidth no longer causes false-positive for h param ; V1toV2: Verify that control [MyLV] is accurate

fcV2GC("","MyLV").move(x, , yes this.is[(width())], height + 1.5) ; V1toV2: Verify that control [MyLV] is accurate

fcV2GC("","MyLV").move(, , , (1 - vol*mastervol) * 300) ; V1toV2: Verify that control [MyLV] is accurate