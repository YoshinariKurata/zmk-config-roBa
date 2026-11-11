# roBa キーマップの作業メモ

このリポジトリは、分割キーボード roBa（ZMK v0.3、Seeed XIAO nRF52840、右手側にトラックボール、左手側にロータリーエンコーダ）のファームウェア設定です。持ち主は Mac と Windows の両方で、Claude と相談しながらキーマップを更新しています。返答は日本語で。

## もう一方のパソコンからの引き継ぎ

**持ち主が「Windows（または Mac）でやった作業の続きをやって」と言ったら、pull してから `HANDOFF.md` を読み、今いるパソコン宛ての項目を片付ける。** 自分のパソコンではできない作業（Mac の Hammerspoon、Windows の overlay.ps1 など）が出たら、持ち主に伝えたうえで、`HANDOFF.md` のもう一方宛てに書いて push しておく。

## 変更の流れ

1. 作業前に必ず `git pull --ff-only`（Mac と Windows の両方で編集するため）。
2. `config/roBa.keymap` を編集する。
3. コミットして push すると GitHub Actions がビルドする。`gh` は上流（kumamuk-git）を既定のリポジトリにしているので、必ず `-R YoshinariKurata/zmk-config-roBa` を付ける。
4. ビルド待ちとダウンロード:
   ```
   gh run list -R YoshinariKurata/zmk-config-roBa --commit <コミットのSHA> --json databaseId -q ".[0].databaseId"
   gh run watch -R YoshinariKurata/zmk-config-roBa <run ID> --exit-status
   gh run download -R YoshinariKurata/zmk-config-roBa <run ID> -D <保存先>
   ```
   `gh run list -L 1` だと前のコミットのビルドを拾うことがあるので、コミットで絞り、`headSha` が自分のコミットと一致するか確かめる。
   ダウンロードしたら、保存先に残っている古い版は聞かずに消す（古い uf2 を間違えて書き込んだことがある）。
5. 書き込みはリセットボタンを2回押して、出てきたドライブに uf2 をコピーする。キーマップだけの変更なら右手側（`roBa_R-seeeduino_xiao_ble-zmk.uf2`、トラックボール側でセントラル）だけでよい。
6. 図（下記）を更新する。

push してもビルドが始まらないときは、GitHub がフォークのワークフローを止めていることがある（過去に一度あった）。リポジトリの Actions タブで有効化してもらい、`gh workflow run build.yml -R ... --ref main` で手動実行する。

## キーマップ図

https://claude.ai/artifact/3K1rzHMtDKGa16DA9rCfje （同じアカウントの Claude から読み書きできる）

- 図の元ファイルは `diagram/roba-keymap.html`。ブラウザで直接開いても見られる。
- キーマップを変えたら、このファイルの `LAYERS`（各レイヤー43キー）と、Windows モードで違うキーをまとめた `WIN`、注意書きも合わせて直し、上の URL を指定して公開し直してから、キーマップと一緒にコミットする。
- 公開前に、上の URL の今の版を読んで、このファイルと違っていないか確かめる（もう一方のパソコンで先に公開されていることがある）。違っていたら、新しい方に合わせてから直す。
- 図のキーをクリックすると「[Mac・L4 マウス] 右手・上から2段目・右から6番目（今: …）」という説明がコピーされる。持ち主はこれを貼り付けて変更を頼む。
- Mac にはこの図のローカルコピー（`~/Documents/roba/keymap-overlay/keymap.html`、`diagram/roba-keymap.html` の先頭に doctype / charset / viewport の行を足したもの）があり、Hammerspoon が画面に重ねて表示する。Mac で図を直したとき、または pull で図や `mac/hammerspoon` が変わったときは、`sh mac/refresh-overlay.sh` でコピーを作り直して Hammerspoon を再起動する。

## Windows のキーマップ図

Windows には Hammerspoon がないので、`roba_win/keymap-overlay/overlay.ps1`（Windows 専用、リポジトリの隣。ビルドしたファームウェアは `roba_win/firmware/<run ID>`）が代わりをする。Ctrl+Alt+F13 で図を画面の上端に3枚重ね（`#overlay=top&mode=win`）、Ctrl+Alt+F14 で全レイヤーを画面いっぱいに出す（`#overlay&mode=win`）。同じキーでもう一度押すと消え、もう一方を押すと切り替わる。クリックは素通し。Edge の「同期しています」のお知らせが出ないよう `--disable-sync` で起動する。Edge は最前面の指定を自分で外すので、自前の最前面・半透明・クリック素通しの窓に、専用プロファイルの Edge（アプリモード）をはめ込んで出し入れする。図のファイルが更新されていたら、次に出すときに読み直すので、Windows で pull したあとに作り直す必要はない。Ctrl+Alt+K はこの PC で別のものが使っていて登録できなかった。

## キーの位置番号

0〜42。左右それぞれ上段5キー、中段・下段は6キー（内側に1キー多い）、親指は左3・右2。
基本レイヤーのアルファベットは **大西配列**（記号は大西配列にしていない）。

```
 0 Q   1 L   2 U   3 ,   4 .            5 F   6 W   7 R   8 Y   9 P
10 E  11 I  12 A  13 O  14 -  15 Tab   16 /  17 K  18 T  19 N  20 S  21 H
22 Z  23 X  24 C  25 V  26 '  27 :     28 ;  29 G  30 D  31 M  32 J  33 B
34 ⌃  35 ⌥  36 ⌘  37 記号  38 Space  39 切替    40 ⌫  41 Enter   42 Del
```

## レイヤー

| 番号 | 名前 | 入り方 |
|---|---|---|
| 0 | 基本 | |
| 1 | SYMBOL 記号 | 37（左親指・左）を押している間 |
| 2 | NUM 数字 | 39（左親指・右）を2回押し。1回押しでどのレイヤーからも基本へ戻る |
| 3 | ARROW（今は Shift などの仮置き） | 39 を長押し。Z の位置が唯一の Shift、Enter（41）が Shift+Enter（Mac・Windows 共通） |
| 4 | MOUSE | トラックボールを動かすと自動で入る（閾値 10、10分で解除）。空きキーは全部 `&none` |
| 5 | SCROLL・F キー | マウスレイヤーの Y 長押しでスクロール。数字レイヤーの 1 の位置（`&sl 5`）で次の1キーが F キー |
| 6 | 設定・BT | 4（`.`）を1秒長押し |
| 7 | WIN | Windows・Android モードの上書き |
| 8〜12 | WIN_NUM / WIN_ARROW / WIN_MOUSE / WIN_SCROLL / WIN_SYMBOL | 7 と 2〜5、1 の条件付きレイヤー |
| 13 | MOUSE_NAV | 3 と 4 の条件付き（マウスレイヤー中に 39 を長押し）。R の位置で戻る（⌘[）、P の位置で進む（⌘]）。ほかはマウスレイヤーのまま |
| 14 | WIN_MOUSE_NAV | 7 と 3 と 4 の条件付き。Windows・Android モードの 13（Alt+← / Alt+→） |

- レイヤーは ZMK の上限 32 まで作れ、容量にも余裕がある。OS で送るキーが違う機能は Mac 用と Windows 用の2つ組にする。上下の順を変えたいときは番号を振り直さず、条件付きレイヤーで上に乗せる。
- レイヤー番号はコンボの `layers`、条件付きレイヤー、トラックボールの `automouse-layer` / `scroll-layers`、Mac の Hammerspoon（⌃⌥⇧⌘ + 0〜6）が参照しているので、振り直さない。使わなくなったレイヤーも空のまま残す。
- 39 のタップ判定は持ち主の2回押しを実測して決めた（2回押しの間隔 450ms、長押しの境目 500ms）。

## 接続先と OS モード

`.` を1秒押したまま右手で選ぶ。電源を入れ直すと Mac モードに戻る。

| キー | 接続先 | 機器 | モード |
|---|---|---|---|
| F | 1 | MacBook | Mac（`&to 0`） |
| W | 2 | Windows | Windows・Android（`&to 7`） |
| R | 3 | Android | Windows・Android（`&to 7`） |
| Y | 4 | 未使用 | Windows・Android（`&to 7`） |
| P | 5 | 未使用 | 切り替えない |

Windows・Android モードでは、Mac 用のキーを WIN 系レイヤーで上書きする（⌘ → Ctrl など、かな/英数は変換/無変換）。

## モニターの入力切り替え

モニターは EIZO FlexScan EV3450XC。Windows = DisplayPort、Mac = USB-C、Nintendo Switch 2 = HDMI 1。互換性モードはオン。
DDC/CI では応答しないので、EIZO の **Screen InStyle**（両方の PC に入れる）のホットキーで切り替える。

| ホットキー | 入力 |
|---|---|
| Ctrl+Shift+J | HDMI 1（Switch 2） |
| Ctrl+Shift+K | DisplayPort（Windows） |
| Ctrl+Shift+L | USB-C（Mac） |

- キーボードはホットキーを**今つながっている PC** に送り、その PC の Screen InStyle がモニターを切り替える。どちらの PC で受けても同じ入力になるよう、両方に同じ3つを登録してある（2026-11-11、持ち主が登録）。今つながっている PC がロック中・スリープ中だと切り替わらない。
- Mac の Screen InStyle では Alt（⌥）をホットキーに組み込めなかったので、両方とも Ctrl+Shift にそろえた（以前の Windows は Ctrl+Alt+8 / 9 / 0）。Mac の「Ctrl」は ⌃ Control として送っている。
- 設定・BT レイヤーの K の位置（17）が Ctrl+Shift+J（Switch 2 へ）。

## ⌃⌥⇧⌘（Hyper）キー

Mac では Hammerspoon が受け取る。設定はこのリポジトリの `mac/hammerspoon/`（`init.lua` が各 lua を読む）で、Mac の `~/.hammerspoon/init.lua` はここを dofile しているだけ。Windows からも読めるので、Mac の表示の大きさや位置はここで確かめる。変えたら Mac で `sh mac/refresh-overlay.sh`（Hammerspoon の再起動を兼ねる）。lua が書き出す確認用のファイル（`*-check.txt` など）は `~/Documents/roba/keymap-overlay/` に出る。

| キー | 動き | 置き場所 |
|---|---|---|
| 0〜6 | キーマップ図の表示を切り替え | `'` + `:` の同時押し |
| D | 全レイヤーの詳しいキーマップ図を画面いっぱいに表示（`#overlay=full`、3列。0〜6 の図とは切り替えで、重ねない） | `V` + `:` の同時押し |
| N | 通知を消す | マウス `,` の位置 |
| F | Finder を前に出す | マウス F の位置 |
| Y | ¥（日本語入力中は「円」） | 数字 |
| B J K L M | 「」（）『』［］【】をペアで入力してカーソルを中へ | 記号 |
| O | … | 記号 |

**Windows では ⌃⌥⇧⌘ が Office を開いてしまう**ので、Hyper を送るキーは Windows 用レイヤー（WIN_MOUSE、WIN_NUM、WIN_SYMBOL）で必ず `&none` か Windows 用のキーに上書きする。

## 同時押し（コンボ）

- `/` + K で英数、`/` + T でかな（Windows では無変換 / 変換）
- `-` + Tab で ⇧Tab
- `'` + `:` でキーマップ図（Mac は ⌃⌥⇧⌘ + レイヤー番号。Windows モード（レイヤー7〜12）では Ctrl+Alt+F13 を送る。下の「Windows のキーマップ図」）
- `V` + `:` で全レイヤーの詳しいキーマップ図（Mac は ⌃⌥⇧⌘D、Windows モードでは Ctrl+Alt+F14）
- F キーへの切り替え後、1 + 2 で F12

持ち主は同時押しを最小限にしたい方針。誤爆しそうな組み合わせ（ローマ字で続けて打つキー同士）は提案前に指摘する。

## 持ち主の好み

- 「一旦要望を聞くだけにして」と言われたら、変更せずに要望を一覧にして相談し、「変更して」「実装して」と言われてからまとめて反映する。
- 記号の置き場所は持ち主が決める。頼まれていない記号を足さない。
- 1つのキーに機能を詰め込むより、分かりやすさを優先する。迷ったら推奨を1つ添えて聞く。
