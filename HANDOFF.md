# もう一方のパソコンへの引き継ぎ

持ち主が「Windows（または Mac）でやった作業の続きをやって」と言ったら、このファイルの、今いるパソコン宛ての項目を上から順に片付ける。
終わった項目は消し、宛ての項目がなくなったら見出しだけ残す。CLAUDE.md の記述も実際に合わせて直し、まとめてコミットして push する。
迷う点は推奨を1つ添えて持ち主に聞く（CLAUDE.md の「持ち主の好み」）。

## Mac 宛て（2026-11-11、Windows から）

ファームウェアはキーボード本体に入っているので、Windows で書き込み済みなら Mac で書き込み直す必要はない（`99b95d4` 以降を書き込んでいれば下の 2 が効く）。

1. **キーマップ図のローカルコピーを作り直して Hammerspoon を再起動する。**
   図（`diagram/roba-keymap.html`）に、Windows で次の2つを入れた。
   - オーバーレイ（`#overlay`）で、人差し指のホームポジション（位置13 の O と 18 の T）に、オレンジの枠と下の横棒の目印を付けた。全カードの同じ位置に出る。
   - `#overlay` に `&mode=win` を付けると Windows・Android モードで描く（Windows 用）。付けなければ今までどおり Mac モード。
   - 全レイヤーの表示（`#overlay`、`=top` なし）では、各カードの左手と右手の間に「このレイヤーへの入り方」（`LAYERS` の `enter`）をオレンジの太字で出す。上端3枚の表示（`#overlay=top`）には出さない。

2. **Hammerspoon で ⌃⌥⇧⌘D を受け取り、全レイヤーの詳しい図を画面いっぱいに出す。**（`~/Documents/roba/keymap-overlay/*.lua`）
   - キーボードは `V` + `:` の同時押し（位置25 と 27、コンボ `keymap_full`、レイヤー0〜6）で ⌃⌥⇧⌘D を送る。
   - 出すのは `keymap.html#overlay`（全レイヤーのカード）。画面いっぱいに使い、カードは画面に収まるように並べる。Windows では図のコピーに次の CSS を足し、窓全体を不透明度 0.92 で透かしている（`overlay.ps1` はリポジトリの外なので、ここに写しておく。3列は 3440×1440 の画面に合わせて計算した数）。
     ```css
     html.overlay, html.overlay body { background: #08090b !important; } html.overlay .card { background: #1b1e25 !important; }
     html.overlay .stack { display: grid !important; grid-template-columns: repeat(3, 1fr); gap: 24px !important; padding: 24px; box-sizing: border-box; min-height: 100vh; align-content: center; }
     html.overlay .minilabel { font-size: 15px !important; top: 8px !important; }
     ```
     この並べ方を Mac でも使うなら、図の側に入れて両方で共有してもよい。
   - **⌃⌥⇧⌘0〜6（`'` + `:`）の図とは切り替えにして、重ねない。** 同じキーをもう一度押すと消え、表示中にもう一方を押すと、そちらに切り替わる。
   - 終わったら CLAUDE.md の ⌃⌥⇧⌘ の表の D の行から「Mac の Hammerspoon 側はまだ未対応」を消す。

3. **（持ち主に聞いてから）Hammerspoon の設定をリポジトリにも置くか相談する。**
   Windows 側は、Mac のオーバーレイの大きさ・位置がわからず、見た目を合わせるのに苦労した。`keymap-overlay` の lua をリポジトリ（例: `mac/keymap-overlay/`）に置いてよいか、持ち主に聞く。置く場合は、置き場所と同期のしかたを CLAUDE.md に書く。

## Windows 宛て

（なし）
