# roBa キーマップの作業メモ

このリポジトリは、分割キーボード roBa（ZMK v0.3、Seeed XIAO nRF52840、右手側にトラックボール、左手側にロータリーエンコーダ）のファームウェア設定です。持ち主は Mac と Windows の両方で、Claude と相談しながらキーマップを更新しています。返答は日本語で。

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
5. 書き込みはリセットボタンを2回押して、出てきたドライブに uf2 をコピーする。キーマップだけの変更なら右手側（`roBa_R-seeeduino_xiao_ble-zmk.uf2`、トラックボール側でセントラル）だけでよい。
6. 図（下記）を更新する。

push してもビルドが始まらないときは、GitHub がフォークのワークフローを止めていることがある（過去に一度あった）。リポジトリの Actions タブで有効化してもらい、`gh workflow run build.yml -R ... --ref main` で手動実行する。

## キーマップ図

https://claude.ai/artifact/3K1rzHMtDKGa16DA9rCfje （同じアカウントの Claude から読み書きできる）

- 図の元ファイルは `diagram/roba-keymap.html`。ブラウザで直接開いても見られる。
- キーマップを変えたら、このファイルの `LAYERS`（各レイヤー43キー）と、Windows モードで違うキーをまとめた `WIN`、注意書きも合わせて直し、上の URL を指定して公開し直してから、キーマップと一緒にコミットする。
- 公開前に、上の URL の今の版を読んで、このファイルと違っていないか確かめる（もう一方のパソコンで先に公開されていることがある）。違っていたら、新しい方に合わせてから直す。
- 図のキーをクリックすると「[Mac・L4 マウス] 右手・上から2段目・右から6番目（今: …）」という説明がコピーされる。持ち主はこれを貼り付けて変更を頼む。
- Mac にはこの図のローカルコピー（`~/Documents/roba/keymap-overlay/keymap.html`、`diagram/roba-keymap.html` の先頭に doctype / charset / viewport の行を足したもの）があり、Hammerspoon が画面に重ねて表示する。Mac で作業するときは、図を直したらこのコピーも作り直して Hammerspoon を再起動する。Windows で直した場合は、次に Mac で pull したときに作り直す。

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
| 3 | ARROW（今は Shift だけの仮置き） | 39 を長押し。Z の位置が唯一の Shift |
| 4 | MOUSE | トラックボールを動かすと自動で入る（閾値 10、10分で解除）。空きキーは全部 `&none` |
| 5 | SCROLL・F キー | マウスレイヤーの Y 長押しでスクロール。数字レイヤーの 1 の位置（`&sl 5`）で次の1キーが F キー |
| 6 | 設定・BT | 4（`.`）を1秒長押し |
| 7 | WIN | Windows・Android モードの上書き |
| 8〜12 | WIN_NUM / WIN_ARROW / WIN_MOUSE / WIN_SCROLL / WIN_SYMBOL | 7 と 2〜5、1 の条件付きレイヤー |

- レイヤー番号はコンボの `layers`、条件付きレイヤー、トラックボールの `automouse-layer` / `scroll-layers`、Mac の Hammerspoon（⌃⌥⇧⌘ + 0〜6）が参照しているので、振り直さない。使わなくなったレイヤーも空のまま残す。
- 39 のタップ判定は持ち主の2回押しを実測して決めた（2回押しの間隔 450ms、長押しの境目 500ms）。

## 接続先と OS モード

`.` を1秒押したまま右手で選ぶ。F=接続先1、W=2（どちらも Mac モード、`&to 0`）、R=3、Y=4（Windows・Android モード、`&to 7`）、P=5（モードは切り替えない）。電源を入れ直すと Mac モードに戻る。

Windows・Android モードでは、Mac 用のキーを WIN 系レイヤーで上書きする（⌘ → Ctrl など、かな/英数は変換/無変換）。

## ⌃⌥⇧⌘（Hyper）キー

Mac では Hammerspoon（Mac 専用、`~/Documents/roba/keymap-overlay/*.lua`）が受け取る。

| キー | 動き | 置き場所 |
|---|---|---|
| 0〜6 | キーマップ図の表示を切り替え | `'` + `:` の同時押し |
| N | 通知を消す | マウス `,` の位置 |
| F | Finder を前に出す | マウス F の位置 |
| Y | ¥（日本語入力中は「円」） | 数字 |
| B J K L M | 「」（）『』［］【】をペアで入力してカーソルを中へ | 記号 |
| O | … | 記号 |

**Windows では ⌃⌥⇧⌘ が Office を開いてしまう**ので、Hyper を送るキーは Windows 用レイヤー（WIN_MOUSE、WIN_NUM、WIN_SYMBOL）で必ず `&none` か Windows 用のキーに上書きする。

## 同時押し（コンボ）

- `/` + K で英数、`/` + T でかな（Windows では無変換 / 変換）
- `-` + Tab で ⇧Tab
- `'` + `:` でキーマップ図（Mac）
- F キーへの切り替え後、1 + 2 で F12

持ち主は同時押しを最小限にしたい方針。誤爆しそうな組み合わせ（ローマ字で続けて打つキー同士）は提案前に指摘する。

## 持ち主の好み

- 「一旦要望を聞くだけにして」と言われたら、変更せずに要望を一覧にして相談し、「変更して」「実装して」と言われてからまとめて反映する。
- 記号の置き場所は持ち主が決める。頼まれていない記号を足さない。
- 1つのキーに機能を詰め込むより、分かりやすさを優先する。迷ったら推奨を1つ添えて聞く。
