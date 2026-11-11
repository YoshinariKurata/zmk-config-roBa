# もう一方のパソコンへの引き継ぎ

持ち主が「Windows（または Mac）でやった作業の続きをやって」と言ったら、このファイルの、今いるパソコン宛ての項目を上から順に片付ける。
終わった項目は消し、宛ての項目がなくなったら見出しだけ残す。CLAUDE.md の記述も実際に合わせて直し、まとめてコミットして push する。
迷う点は推奨を1つ添えて持ち主に聞く（CLAUDE.md の「持ち主の好み」）。

## Mac 宛て

（なし）

## Windows 宛て（2026-11-11、Mac から）

1. **図に全画面表示のモード `#overlay=full` を入れた。** 全レイヤーを3列で並べ、背景を暗く少し透かす（Windows で overlay.ps1 が足していた CSS とほぼ同じ）。Mac では Hammerspoon が ⌃⌥⇧⌘D でこれを出す。Windows の Ctrl+Alt+F14 も、CSS を足す代わりに `#overlay=full&mode=win` を開くように変えれば、Mac と見た目をそろえられる（任意。持ち主に聞いてから）。
2. **モニターのホットキーを Ctrl+Shift+J / K / L に変えた**（持ち主が両方の Screen InStyle に登録済み）。キーボードの設定・BT の K は Ctrl+Shift+J を送る。Windows で以前の Ctrl+Alt+8 / 9 / 0 が Screen InStyle に残っていたら、持ち主に聞いて消す。
