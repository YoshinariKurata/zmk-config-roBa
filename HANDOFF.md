# もう一方のパソコンへの引き継ぎ

持ち主が「Windows（または Mac）でやった作業の続きをやって」と言ったら、このファイルの、今いるパソコン宛ての項目を上から順に片付ける。
終わった項目は消し、宛ての項目がなくなったら見出しだけ残す。CLAUDE.md の記述も実際に合わせて直し、まとめてコミットして push する。
迷う点は推奨を1つ添えて持ち主に聞く（CLAUDE.md の「持ち主の好み」）。

## Mac 宛て

## Windows 宛て（2026-11-11、Mac から）

1. **図に全画面表示のモード `#overlay=full` を入れた。** 全レイヤーを3列で並べ、背景を暗く少し透かす（Windows で overlay.ps1 が足していた CSS とほぼ同じ）。Mac では Hammerspoon が ⌃⌥⇧⌘D でこれを出す。Windows の Ctrl+Alt+F14 も、CSS を足す代わりに `#overlay=full&mode=win` を開くように変えれば、Mac と見た目をそろえられる（任意。持ち主に聞いてから）。
2. **Windows につないだ状態で、設定・BT の F を押してモニターも Mac（USB-C）に切り替わるか確かめる。** Mac から W（Windows へ）で切り替わることは確認済み（2026-11-12、`e1ea8a5`）。Mac の Screen InStyle は短すぎるキー押しを「suppressed」として取り消したので、マクロは 150ms 押して 0.5 秒待ってから接続先を変える。Windows でも切り替わらなければ、Windows の Screen InStyle のログを見る。
