#!/bin/sh
# Mac 専用: キーマップ図のローカルコピーを作り直して、Hammerspoon を再起動する。
# 図 (diagram/roba-keymap.html) を変えたあとや、Windows の変更を pull したあとに実行する。
# Hammerspoon は file:// で開くので、文字化けしないよう先頭に doctype / charset / viewport を足す。

REPO=$(cd "$(dirname "$0")/.." && pwd)
DST="$HOME/Documents/roba/keymap-overlay/keymap.html"
mkdir -p "$(dirname "$DST")"
{
  echo '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">'
  cat "$REPO/diagram/roba-keymap.html"
} > "$DST"
echo "updated $DST"
killall Hammerspoon
sleep 2
open -a Hammerspoon
sleep 3
pgrep -lx Hammerspoon
