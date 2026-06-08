
; fixes for truncation and false positives

ogcMyLV.move(400, 50, 20)

ogcMyLV.move(, , width, height)  ; width/height no longer truncated

ogcMyLV.move(, , halfWidth)  ; halfWidth no longer causes false-positive for h param

ogcMyLV.move(x, , yes this.is[(width())], height + 1.5)

ogcMyLV.move(, , , (1 - vol*mastervol) * 300)