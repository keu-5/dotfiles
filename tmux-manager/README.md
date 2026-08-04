# tmux Manager

tmux 環境のセットアップと管理を行うディレクトリです。
SSH が切れても remote 側の作業（主に Claude Code の対話セッション）が生き残るようにするためのものです。

## ファイル構成

```text
tmux-manager/
├── README.md           # このファイル
├── setup-tmux.sh       # tmux環境セットアップスクリプト（SSH先で実行する）
└── push-terminfo.sh    # 手元の端末の terminfo を SSH 先へ送る（★手元PCで実行する）

.config/tmux/
└── tmux.conf           # tmux 設定ファイルの実体
```

2つのスクリプトは実行する場所が違います。`setup-tmux.sh` は設定を置きたいマシン（＝SSH 先）で、
`push-terminfo.sh` は端末が動いているマシン（＝手元PC）で実行します。

## なぜ tmux を使うのか

ノートPCから SSH で繋いで作業していると、スリープや回線の切断で SSH が落ちます。
このとき、SSH で起動したプロセスは端末（pty）ごと消え、Claude Code の対話セッションも作業文脈も失われます。

tmux は、**プロセスを SSH の端末ではなく、remote 側で常駐する tmux サーバにぶら下げます**。
SSH が切れても死ぬのは画面を映していたクライアントだけで、サーバとその中のプロセスは remote 側に残ります。
繋ぎ直して attach すれば、画面の内容ごと続きから再開できます。

## セットアップ

```bash
./tmux-manager/setup-tmux.sh
```

このスクリプトは以下の処理を行います。

1. **前提条件の確認**
   - tmux の存在確認（見つからない場合は案内して終了する。自動インストールはしない）
   - tmux のバージョン確認（設定ファイルの置き場所の判定に使う）
2. **設定ファイルのリンク作成**
   - `~/.config/tmux` → `dotfiles/.config/tmux` のシンボリックリンク作成
   - 既存の設定がある場合は日時付きでバックアップ
   - `~/.tmux.conf` が残っていると両方読まれて混乱するため退避する
3. **設定の検証**
   - リンクの確認
   - 別ソケット（`-L setupcheck`）の一時サーバで設定を実際に読み込ませ、文法エラーがないか確認する
     （**動作中の tmux サーバやセッションには一切触らない**）
   - terminfo の確認（後述の落とし穴の予防）

## 毎回の作業手順

```bash
# 1. remote に入る
ssh rtx4070ti

# 2. tmux セッションに入る（無ければ作成、あれば再接続）
tmux new-session -A -s main

# 3. この中で作業する
claude

# 4. 離れるときは detach（画面から抜けるだけ。中のプロセスは動き続ける）
#    キー操作: Ctrl-b を押して離してから d
```

ノートPCがスリープして SSH が切れた場合も、何もしなくてかまいません。次に繋ぎ直したとき、

```bash
ssh rtx4070ti
tmux ls                      # 残っているセッションを確認
tmux attach -t main          # 続きから再開
```

で戻れます。`tmux new-session -A -s main` は「あれば attach、無ければ作成」なので、
手順 2 のコマンドをそのまま再実行しても構いません。

## 日常的に使うキー操作

tmux の操作は **prefix キー（`Ctrl-b`）を押して離してから、次のキーを押す**という形です。
この設定では prefix は既定の `Ctrl-b` のままにしています。

| キー操作          | 何が起きるか                                     |
| ----------------- | ------------------------------------------------ |
| `Ctrl-b` `d`      | detach（セッションを残して画面から抜ける）       |
| `Ctrl-b` `c`      | 新しいウィンドウを作る                           |
| `Ctrl-b` `1`〜`9` | 番号のウィンドウへ移動                           |
| `Ctrl-b` `n`／`p` | 次／前のウィンドウへ移動                         |
| `Ctrl-b` `w`      | ウィンドウ一覧から選ぶ                           |
| `Ctrl-b` `%`      | ペインを左右に分割                               |
| `Ctrl-b` `"`      | ペインを上下に分割                               |
| `Ctrl-b` `矢印`   | 隣のペインへ移動                                 |
| `Ctrl-b` `[`      | コピーモードに入る（スクロールして遡る）。`q` で抜ける |
| `Ctrl-b` `r`      | tmux.conf を読み直す（この設定で追加したもの）   |
| `Ctrl-b` `?`      | キー一覧を表示する。`q` で抜ける                 |

マウスを有効にしてあるので、スクロール・ペインの選択・境界のドラッグはマウスでもできます。

## セッションの確認・再接続・終了

```bash
tmux ls                      # セッション一覧（サーバが無ければ "no server running" と出る）
tmux attach -t main          # 指定セッションに再接続
tmux new-session -A -s main  # あれば attach、無ければ作成
tmux list-clients            # いま接続しているクライアント

tmux kill-session -t main    # このセッションだけ終了する
tmux kill-server             # 全セッションを終了する（他の作業も巻き込むので普段は使わない）
```

セッションは detach しても消えません（`destroy-unattached` が既定の off のため）。
消えるのは次の場合です。

- セッション内の最後のウィンドウのプロセスが終了したとき（シェルで `exit` した、`Ctrl-d` を押した）
- `tmux kill-session` / `tmux kill-server` を実行したとき
- マシンが再起動したとき

なお tmux サーバのソケットは `/tmp/tmux-$(id -u)/` にありますが、Ubuntu の `tmpfiles.d` 設定は
`/tmp` を**起動時にのみ**作り直す（`D /tmp 1777 root root -`）ので、稼働中に消えることはありません。

## 長時間の実験ジョブとの役割分担

**tmux は「対話セッションを切断から守るもの」であって、「ジョブを守るもの」ではありません。**

長時間動かす実験ジョブは、これまで通り `nohup` / `setsid` で端末から切り離して実行します。

```bash
nohup python train.py > train.log 2>&1 &
# または
setsid python train.py > train.log 2>&1 < /dev/null &
```

理由は、ジョブの生存を tmux に依存させないためです。
tmux の中でジョブを起動すると、そのジョブの親は tmux サーバになります。
`tmux kill-server` や、うっかりウィンドウを閉じる操作、サーバ側の異常終了が、そのままジョブの死につながります。
`nohup` / `setsid` で切り離しておけば、tmux が落ちてもジョブは無関係に走り続けます。

使い分けは次の通りです。

| やりたいこと                         | 使うもの                                  |
| ------------------------------------ | ----------------------------------------- |
| Claude Code など対話的な作業を続ける | tmux                                      |
| 長時間の学習・実験ジョブを流す       | `nohup` / `setsid`（tmux の中から流してもよい） |
| ジョブの進捗を眺める                 | tmux の中で `tail -f train.log`           |

tmux の中から `nohup` でジョブを起動するのは問題ありません。ジョブは tmux から切り離されるので、
tmux 側が消えてもジョブは残ります。

## 落とし穴と対処

### 1. `missing or unsuitable terminal: xterm-ghostty` で attach できない

このマシン（rtx4070ti / Ubuntu 22.04）には Ghostty の terminfo が入っていません。
`echo $TERM` が `xterm-ghostty` のまま tmux を起動すると、次のように失敗します。

```console
$ tmux
missing or unsuitable terminal: xterm-ghostty
```

**その場しのぎ**（すぐ使いたいとき）:

```bash
TERM=xterm-256color tmux new-session -A -s main
```

**恒久対処**（手元PC側で1回実行する）。手元にある terminfo を SSH 先の `~/.terminfo` に送り込みます。
root 権限もパッケージのインストールも不要です。

```bash
# ↓ これは remote ではなく「手元のノートPC」で、dotfiles のディレクトリで実行する
./tmux-manager/push-terminfo.sh rtx4070ti
```

引数は `ssh` に渡すのと同じ指定なので、`user@host` の形でも構いません。複数台まとめても実行できます。
送る terminfo は既定で現在の `$TERM` です。tmux の中から実行する場合は `$TERM` が tmux 自身のものに
なっているため、`--term xterm-ghostty` のように明示してください（スクリプトも警告します）。

やっていることは Ghostty 公式ドキュメントが案内する次の 1 行と同じです。

```bash
infocmp -x xterm-ghostty | ssh rtx4070ti -- tic -x -
```

スクリプトはこれに加えて、書き込み先を `~/.terminfo` に固定し（`tic` は既定ではシステムの
terminfo データベースへ書こうとし、権限が無い場合にのみ `~/.terminfo` へ回るため、
root かどうかで置き場所が変わらないようにする）、転送後に SSH 先で実際に引けるかを確認します。

送り込んだあとは、`TERM` を変えずに `tmux` がそのまま起動します。

#### `tic` の警告は無視してよい

転送時、次の警告が出ることがあります。**これは互換性の注意であって失敗ではありません**（`tic` の終了コードは 0）。

```console
"<stdin>", line 2, col 31, terminal 'xterm-ghostty': older tic versions may treat the description field as an alias
```

エントリの先頭行は `xterm-ghostty|ghostty|Ghostty,` という形で、最後の `Ghostty` は説明文です。
これを古い `tic` はエイリアス（別名）と誤解しうる、という注意です。導入結果には影響しません。
`push-terminfo.sh` は転送後に SSH 先で `infocmp` を引いて成否を判定するので、
この警告が出ていても「検証は通っています」と明示して表示します。

成功したかどうかは SSH 先で次のように確認できます。

```bash
infocmp xterm-ghostty >/dev/null && echo OK
```

> 検証状況: SSH 先（rtx4070ti / Ubuntu 22.04, ncurses 6.3）に `~/.terminfo/x/xterm-ghostty` が
> 置かれ、`TERM=xterm-ghostty` のまま tmux が起動することを実測済み。上記の警告も再現し、
> 終了コードが 0 で導入が成功することを確認済み。
> `push-terminfo.sh` 自体は、`ssh` を差し替えた代役でローカルに転送・検証・失敗時の挙動を確認済み。
> 手元PCの Ghostty から実際に走らせた結果は未検証（SSH 先からは手元PCを操作できないため）。

### 2. 再接続しても、既に開いていたシェルの環境変数は古いまま

detach 前と別の SSH 接続から attach し直すと、`SSH_CONNECTION` や `SSH_AUTH_SOCK` などが
**セッション側では更新される**（`update-environment` の既定動作）一方、
**既に開いているペインのシェルは古い値を持ったまま**になります。
`ssh-agent` 転送を使っていると、古い `SSH_AUTH_SOCK` を掴んだままで git push が失敗する、という形で表面化します。

- 新しく作ったウィンドウ・ペインには新しい値が入っている
- 既存のペインで直したいときは、そのペインで次を実行する

```bash
eval "$(tmux show-environment -s SSH_AUTH_SOCK)"
```

### 3. マウスを有効にすると端末側の文字選択ができない

`mouse on` にしているため、ドラッグは tmux のコピーモードに取られます。
端末（Ghostty など）自身の選択を使いたいときは `Shift` を押しながらドラッグします。
（多くの端末で共通の挙動ですが、Ghostty での動作は未検証です。）

### 4. `~/.tmux.conf` を作ると設定が二重に読まれる

tmux は設定ファイルを「最初に見つかった1つ」ではなく、**存在するものを順に全部**読みます
（`~/.tmux.conf` → `~/.config/tmux/tmux.conf` の順）。
両方あると後から読まれた側が勝ち、editing しても効かないという混乱が起きます。
`setup-tmux.sh` は `~/.tmux.conf` を見つけたら日時付きで退避します。

## 導入した設定（`.config/tmux/tmux.conf`）

対象は tmux 3.2a（Ubuntu 22.04 の apt 版）です。
既定値は実機の `tmux show-options -g -A` / `-s -A` / `-w -g -A` で確認しています。
「既定のままでは困るもの」だけを入れており、根拠の薄いものは入れていません。

| 設定                                    | 既定値     | 入れた理由                                                                             |
| --------------------------------------- | ---------- | -------------------------------------------------------------------------------------- |
| `default-terminal "tmux-256color"`      | `screen`   | tmux が持つ機能（256色、修飾キー付きのキー入力等）を中のアプリへ正しく伝えるため        |
| `terminal-features ",xterm*:RGB"`       | 未設定     | 外側の端末が truecolor を扱えると tmux に教える。無いと 24bit 色が 256 色に丸められる    |
| `escape-time 10`                        | `500`（ms）| Esc 単独かキー列かを待つ時間。既定だと nvim のモード切り替えがそのぶん遅れる            |
| `history-limit 50000`                   | `2000`     | Claude Code の長い出力を遡れるようにする。1ペインあたりなのでメモリと引き換え           |
| `mouse on`                              | `off`      | スクロール・ペイン選択・サイズ変更をマウスでできるようにする                            |
| `base-index 1` / `pane-base-index 1`    | `0`        | キーボードの数字の並びに合わせる                                                        |
| `renumber-windows on`                   | `off`      | ウィンドウを閉じたときに番号を詰める（off だと 1,3,4 と穴が残る）                       |
| `set-clipboard on`                      | `external` | SSH 先の nvim などが tmux 越しに手元PCのクリップボードへコピーできるようにする（OSC 52）|
| `focus-events on`                       | `off`      | フォーカスの出入りを中のアプリへ伝える（nvim の autoread 等）                           |
| `mode-keys vi`                          | `emacs`    | コピーモードの移動キーを nvim に合わせる                                                |
| `bind r source-file ...`                | 未設定     | 設定を編集したあと `Ctrl-b r` で読み直せるようにする                                    |

入れなかったものと、その理由も設定ファイル末尾に書いてあります。

- `aggressive-resize`: 既定の `window-size latest` の下では効果がない
- `allow-passthrough`: tmux 3.3 以降のオプションで、3.2a には存在しない
- プラグイン管理（TPM）: 今回の目的に不要なので依存を増やさない
- prefix の変更: `Ctrl-a` は行頭移動と衝突するため既定の `Ctrl-b` のまま

### `set-clipboard on` の注意

`on` は「tmux の中で動くアプリが手元PCのクリップボードを書き換えられる」という意味です。
既定の `external` はこれを許しません。素性の知れないコマンドの出力をそのまま流すと
クリップボードを書き換えられる可能性がある、という点だけ意識しておいてください。

> 検証状況: 設定が有効になっていること（`set-clipboard on`）と、terminfo に OSC 52 用の
> `Ms` があることは確認済み。実際に手元PCのクリップボードへ入るかは、端末側の対応と設定にも
> 依存するため未検証（Ghostty 側で無効化されていれば効かない）。

## トラブルシューティング

### 設定を変えたのに反映されない

tmux は起動時に設定を読みます。既に動いているセッションには自動で反映されません。

```bash
tmux source-file ~/.config/tmux/tmux.conf   # または tmux の中で Ctrl-b r
```

### リンク作成に失敗した場合

1. 現状を確認：

   ```bash
   ls -la ~/.config/tmux*
   ```

2. 手動でリンクを削除：

   ```bash
   rm ~/.config/tmux
   ```

3. スクリプトを再実行：

   ```bash
   ./tmux-manager/setup-tmux.sh
   ```

### 設定が壊れて tmux が起動しない

設定を読まずに起動して切り分けます。

```bash
tmux -f /dev/null new-session -A -s rescue
```
