#!/usr/bin/env bash
# headless_batch_convert.sh - RunAny official plugin corpus pipeline
# (local fork deployment script; converter core stays layout-agnostic).
#
# 1. Converts every plugin headlessly into a FLAT output tree.
#    RunAny_ObjReg.ahk MUST convert first: other plugins #Include it and the
#    include normalizer checks that the target already exists in outDir.
# 2. Deploys the hand-maintained Lib assets (JSON adapter + JXON). These are
#    NOT converter output - the v1 coco JSON library is deliberately not
#    converted (converter-plugin-breakage.md #8/#9); the adapter bridges
#    JSON.Load -> Jxon_Load. A GPL'd optional lib (ChToPy) is intentionally
#    not deployed; its #Include *i tolerates absence.
# 3. /validates every output with the canonical engine (exit 0 = loadable).
#
# Usage: headless_batch_convert.sh <srcDir> <outDir> [goldenLibDir]
set -u
SRC="${1:?usage: headless_batch_convert.sh <srcDir> <outDir> [goldenLibDir]}"
OUT="${2:?usage: headless_batch_convert.sh <srcDir> <outDir> [goldenLibDir]}"
GOLDLIB="${3:-}"
AHK="D:/repo/AutoHotkey/bin/AutoHotkey64.exe"
HERE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$OUT"
if [ -n "$GOLDLIB" ] && [ -d "$GOLDLIB" ]; then
  mkdir -p "$OUT/Lib"
  cp -f "$GOLDLIB"/*.ahk "$OUT/Lib/"
fi

order=(
  "RunAny_ObjReg.ahk"
  "RunAny_Menu.ahk"
  "RunCtrl_Common.ahk"
  "RunCtrl_Network.ahk"
  "XiaoYao_plus.ahk"
  "huiZz_BatchRun.ahk"
  "huiZz_InputEnCn.ahk"
  "huiZz_MButton.ahk"
  "huiZz_RestTime.ahk"
  "huiZz_ScoopUpdate.ahk"
  "huiZz_System.ahk"
  "huiZz_Text.ahk"
  "huiZz_VirtualDesktop.ahk"
  "huiZz_Window.ahk"
  "huiZz_Work.ahk"
  "tong_QuickLook.ahk"
  "huiZz_QRCode/huiZz_QRCode.ahk"
  "RunAny_SearchBar/RunAny_SearchBar.ahk"
)

for f in "${order[@]}"; do
  base="$(basename "$f")"
  "$AHK" //ErrorStdOut=UTF-8 "$HERE/headless_convert.ahk" "$SRC/$f" "$OUT/$base" >/dev/null 2>&1 \
    && echo "CONV-OK   $base" || echo "CONV-FAIL $base"
done

pass=0; total=0
for f in "$OUT"/*.ahk; do
  total=$((total+1))
  if "$AHK" //ErrorStdOut=UTF-8 //Validate "$f" >/dev/null 2>&1; then
    pass=$((pass+1)); echo "VALIDATE-OK   $(basename "$f")"
  else
    echo "VALIDATE-FAIL $(basename "$f")"
  fi
done
echo "==== $pass/$total loadable"
[ "$pass" -eq "$total" ]
