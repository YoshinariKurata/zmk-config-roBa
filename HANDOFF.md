# もう一方のパソコンへの引き継ぎ

持ち主が「Windows（または Mac）でやった作業の続きをやって」と言ったら、このファイルの、今いるパソコン宛ての項目を上から順に片付ける。
終わった項目は消し、宛ての項目がなくなったら見出しだけ残す。CLAUDE.md の記述も実際に合わせて直し、まとめてコミットして push する。
迷う点は推奨を1つ添えて持ち主に聞く（CLAUDE.md の「持ち主の好み」）。

## Mac 宛て（2026-11-11、Windows から）

1. **Mac の Screen InStyle のホットキーを Ctrl+Shift+7 / 8 / 9 に変える。**（CLAUDE.md の「モニターの入力切り替え」）
   J / K / L は Windows の Chrome（Ctrl+Shift+J）・Edge・VS Code（Ctrl+Shift+K / L）のショートカットを横取りするので、持ち主と相談して数字に変えた。Windows は登録済み（config.json を書き換え）。
   - 7 = HDMI 1（Switch 2）、8 = DisplayPort（Windows）、9 = USB-C（Mac）。J / K / L の3つは消す。
   - settings.json を書き換えるなら、Modifiers は今の Ctrl+Shift と同じ 5 のまま。数字の Key の番号は J / K / L（9 / 10 / 11）からは推せないので、画面で1つ登録して保存し、settings.json で確かめてから残りを書く。
   - ⌃⇧7 / 8 / 9 が Mac のほかのアプリ（Hammerspoon を含む）と被っていないか確かめる。
2. **接続先の切り替えでモニターも切り替わるか試す。** キーボード（`e2dd1db` の次のコミット以降）は、設定・BT の F（Mac）で Ctrl+Shift+9、W（Windows）で Ctrl+Shift+8 を、接続先を変える前に今つながっている PC へ送る。K は Ctrl+Shift+7（Switch 2）。Mac につながった状態で W を押すと、Mac の Screen InStyle がモニターを DisplayPort にしてから Windows に切り替わるはず。

## Windows 宛て（2026-11-11、Mac から）

1. **図に全画面表示のモード `#overlay=full` を入れた。** 全レイヤーを3列で並べ、背景を暗く少し透かす（Windows で overlay.ps1 が足していた CSS とほぼ同じ）。Mac では Hammerspoon が ⌃⌥⇧⌘D でこれを出す。Windows の Ctrl+Alt+F14 も、CSS を足す代わりに `#overlay=full&mode=win` を開くように変えれば、Mac と見た目をそろえられる（任意。持ち主に聞いてから）。
