#!/usr/bin/env bash
# scripts/generate-samples.sh
#
# silicon を使って、Ioskeley Mono JP で描画したコードサンプル画像を
# assets/ に生成する。README のショーケース画像はこのスクリプトで更新する。
#
# 必要環境:
#   - silicon   (https://github.com/Aloxaf/silicon)
#   - Ioskeley Mono JP フォントがインストール済みであること
#     (`nix develop` / flake の default パッケージ、または Releases から)
#
# 使い方:
#   ./scripts/generate-samples.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SAMPLES_DIR="${SCRIPT_DIR}/samples"
ASSETS_DIR="${ROOT_DIR}/assets"

# リガチャと Nerd Font アイコンを収録した NFLG 版で描画する。
# 未インストールの場合は好みのファミリー名に変更する。
FONT="${SILICON_FONT:-Ioskeley Mono JP NFLG=20}"
THEME="${SILICON_THEME:-Dracula}"
BACKGROUND="${SILICON_BG:-#2b303b}"

mkdir -p "${ASSETS_DIR}"

if ! command -v silicon >/dev/null 2>&1; then
  echo "error: silicon が見つかりません。'nix develop' で開発シェルに入るか、silicon をインストールしてください。" >&2
  exit 1
fi

render() {
  local src="$1" lang="$2" out="$3"
  echo "==> ${out} を生成中 (font: ${FONT})"
  silicon "${SAMPLES_DIR}/${src}" \
    --language "${lang}" \
    --font "${FONT}" \
    --theme "${THEME}" \
    --background "${BACKGROUND}" \
    --shadow-blur-radius 20 \
    --shadow-color '#00000055' \
    --pad-horiz 60 \
    --pad-vert 60 \
    --window-title "${src}" \
    --output "${ASSETS_DIR}/${out}"
}

render sample.rs Rust       sample-rust.png
render sample.ts TypeScript sample-typescript.png
render sample.py Python     sample-python.png

echo "完了: ${ASSETS_DIR} に画像を生成しました。"
