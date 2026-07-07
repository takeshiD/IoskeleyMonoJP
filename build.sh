#!/usr/bin/env bash
# ============================================================
# Ioskeley Mono JP ビルドスクリプト (Linux / macOS)
#
# BIZ UD Gothic (日本語・記号) と Ioskeley Mono (英数字) を合成し、
# udev-gothic 互換の全バリアントを build/ に生成する。
#
# 前提:
#   - fontforge (--lang=py -script が使えるもの)
#   - python3 + fonttools + ttfautohint-py (requirements.txt)
#   - source/ に以下が存在すること:
#       fontforge_export_BIZUDGothic-{Regular,Bold}.ttf  (同梱)
#       ideographic_space.sfd / SymbolsNerdFont-Regular.ttf (同梱)
#       IoskeleyMono-{Regular,Bold,Italic,BoldItalic}.ttf   (Iosevka でビルド)
#       IoskeleyMonoLG-{Regular,Bold,Italic,BoldItalic}.ttf (Iosevka でビルド)
#
# 使い方:
#   ./build.sh            # 全 16 バリアントをビルド
#   ./build.sh --debug    # Regular のみを 1 バリアントだけ (動作確認用)
# ============================================================
set -euo pipefail
cd "$(dirname "$0")"

FONTFORGE_BIN="${FONTFORGE_BIN:-fontforge}"

# デバッグモード: Regular のみ・NF+LG の 1 バリアントだけ生成
if [[ "${1:-}" == "--debug" ]]; then
    echo "=== DEBUG build (Regular only, NFLG) ==="
    rm -rf build && mkdir -p build
    "$FONTFORGE_BIN" --lang=py -script fontforge_script.py --do-not-delete-build-dir --nerd-font --liga --debug
    python3 fonttools_script.py "NFLG-"
    ls -la build/*.ttf
    exit 0
fi

# クリーンビルド
rm -rf build
mkdir -p build

# "fontforge へ渡すオプション|fonttools へ渡すバリアント接頭辞(末尾ハイフン必須)"
combos=(
    "--nerd-font|NF-"                              # 1:2幅 + Nerd Fonts
    "--35 --nerd-font|35NF-"                        # 3:5幅 + Nerd Fonts
    "--nerd-font --liga|NFLG-"                       # 1:2幅 + Nerd Fonts + リガチャ
    "--35 --nerd-font --liga|35NFLG-"                 # 3:5幅 + Nerd Fonts + リガチャ
    "|-"                                             # 1:2幅
    "--35|35-"                                        # 3:5幅
    "--liga|LG-"                                      # 1:2幅 + リガチャ
    "--35 --liga|35LG-"                               # 3:5幅 + リガチャ
    "--jpdoc|JPDOC-"                                  # 1:2幅 JPDOC版
    "--35 --jpdoc|35JPDOC-"                            # 3:5幅 JPDOC版
    "--hidden-zenkaku-space|HS-"                       # 1:2幅 全角スペース不可視
    "--hidden-zenkaku-space --35|35HS-"                 # 3:5幅 全角スペース不可視
    "--hidden-zenkaku-space --liga|HSLG-"               # 1:2幅 全角スペース不可視 + リガチャ
    "--hidden-zenkaku-space --35 --liga|35HSLG-"         # 3:5幅 全角スペース不可視 + リガチャ
    "--hidden-zenkaku-space --jpdoc|HSJPDOC-"            # 1:2幅 全角スペース不可視 JPDOC版
    "--hidden-zenkaku-space --35 --jpdoc|35HSJPDOC-"      # 3:5幅 全角スペース不可視 JPDOC版
)

for entry in "${combos[@]}"; do
    opts="${entry%%|*}"
    variant="${entry##*|}"
    echo "======================================================"
    echo "=== build variant='${variant}' opts='${opts}'"
    echo "======================================================"
    # shellcheck disable=SC2086
    "$FONTFORGE_BIN" --lang=py -script fontforge_script.py --do-not-delete-build-dir $opts
    python3 fonttools_script.py "$variant"
done

echo ""
echo "=== 完成したフォント (build/) ==="
ls -1 build/*.ttf
