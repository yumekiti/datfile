# tmux 設定

端末アプリの背景を活かした Tokyo Night accent 配色 + vim風操作 + ステータスバーにネットワーク/CPU/バッテリーを表示する設定。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `tmux.conf` | 本体設定。tmux 3.1以降は `~/.tmux.conf` が無ければ自動でこのパスを読むので、起動オプション不要 |
| `net_speed.sh` | ステータスバー右側の Network 値（↓下り/↑上り）を出力 |
| `cpu.sh` | ステータスバー右側の CPU 値（使用率%、色分け）を出力 |
| `battery.sh` | ステータスバー右側の Battery 値（`[####-]` バー + 残量%）を出力 |
| `ai_thinking.sh` | Claude Codeの `UserPromptSubmit` フックから呼ばれ、応答中のwindowに `@ai_thinking` フラグを立て、brailleスピナー（`@ai_spinner_frame`）を回す常駐ループを管理する（後述） |
| `win_icon.sh` | 現在未使用。以前ウィンドウ一覧にプログラム名アイコンを出す用に作ったが、中央表示自体をオフにしたため呼ばれていない |

## 起動・反映

```bash
tmux              # 新規セッション（自動でこの設定が読み込まれる）
tmux attach       # 既存セッションに再接続
```

設定ファイルを編集した後は、tmux内で

```
prefix → r
```

を押すとリロードされる（`tmux.conf` 内 `bind r` で定義）。

**prefixキーは `Ctrl-a`**（デフォルトの`Ctrl-b`から変更。小指を伸ばさず届く位置で押しやすいscreen由来の定番設定）。`Ctrl-a`を素の入力として送りたい場合（シェルで行頭に戻る等）は `prefix → Ctrl-a` で送れる。

## ステータスバーの見方

```
 Session: main         Network ↓12K ↑3K  CPU 31%  Memory 69%  Battery [##---] 60%   14:32  07/05(Sat)
```

- **左**：状態表示＋window一覧。色だけでなく文字でも分かるようにしてある。複数の状態が同時に起きても重ならないよう優先順位で1つだけ表示する
  - `prefix` 押下中（赤・最優先）: `Mode: Prefix`
  - sync（全pane同時入力）中（黄）: `Sync: ON`
  - コピーモード中（緑）: `Mode: Visual`
  - 通常時（青）: `Session: セッション名`
  - 直後にwindow一覧（`番号:名前`）を左寄せ表示。今いるwindowだけアクセント背景色（青）が付く
  - Claude Codeがそのwindow内のいずれかのpaneで応答中（プロンプト送信〜応答完了の間）は、window名の手前に緑文字のbrailleスピナー（`⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`を約300msごとにコマ送り）が付く（`Session: main  ⠙ 1:main` のように表示される）。Claude Code側の `~/.claude/settings.json` に登録した `UserPromptSubmit`（応答開始）フックから `ai_thinking.sh` が呼ばれ、window option `@ai_thinking` を立てたときに常駐ループを1本起動し、`@ai_spinner_frame` を書き換えては `tmux refresh-client -S` で明示的に再描画させて回している（`#(...)`job方式だと"status lineは1秒に1回までしか再描画されない"というtmuxのハード制限に当たるため、あえてjobを使っていない）。応答終了の検知は`Stop`/`PostToolUse`フックには頼らず（`Stop`はユーザーの中断では発火しない既知の制約があり、ハートビート監視も中断から消えるまでの遅延が大きくUX的に不十分だったため不採用）、常駐ループ自身がClaude CodeのTUI最下部に出る`esc to interrupt`という文字列をpaneから直接ポーリングして検知している。この文字列が連続3回（約0.9秒）見えなくなったら応答終了とみなしてループを止める（1回のミスで即オフにすると、ツール呼び出しの合間などの一瞬の描画抜けを誤検知してスピナーが早期に消えるため、猶予を設けている）。ただしミスカウントは「一度でもヒント文字列を検知した後」しか始めない。応答開始直後はTUIがまだヒント文字列を描画し切っていないことがあり、これを含めてミス扱いにすると本当は応答中なのにループが数百ms〜1秒で自己終了し、スピナーがほぼ一瞬しか点かない不具合になる（実際に発生を確認）。tmux外や `$TMUX_PANE` が無い環境では何もしない
- **右**：ラベル付きの値を並べている。単語は略さず、色だけに依存しないようにしている
  - `Network ↓.. ↑..` — 下り/上り速度（緑=下り、赤=上り）
  - `CPU NN%` / `Memory NN%` — 使用率。80%以上=赤、50%以上=黄、それ未満=緑
  - `Battery [#####] NNN%` — `=`が塗りつぶし本数（6段階）。充電中は`%+`と表示
  - 時刻・日付（曜日）

すべて絵文字やNerd Font専用アイコンを使わず、標準的な文字だけで構成している（環境によって表示が崩れないようにするため）。

## キーバインド

### pane（画面分割）

| キー | 動作 |
|---|---|
| `prefix` → `\|` | 左右に分割（カレントディレクトリを引き継ぐ） |
| `prefix` → `-` | 上下に分割（同上） |
| `prefix` → `h` / `j` / `k` / `l` | pane移動（vim風、`-r`指定なので連続で押せる） |
| `prefix` → `Ctrl+h` / `j` / `k` / `l` | pane移動（`Ctrl-a`を離さず`h/j/k/l`でも可。`-r`指定なので連続で押せる） |
| `prefix` → `H` / `J` / `K` / `L` | paneリサイズ（`-r`指定なので連続で押せる） |
| `prefix` → `=` | 全paneのレイアウトを均等に揃える |
| `prefix` → `Enter` | 現在のpaneを全画面ズーム（もう一度で解除） |

### window（タブ）

| キー | 動作 |
|---|---|
| `prefix` → `c` | 新規ウィンドウ（カレントディレクトリを引き継ぐ） |
| `prefix` → `C` | 新規セッション（カレントディレクトリを引き継ぐ） |
| `prefix` → `n` / `p` | 次 / 前のウィンドウへ（`-r`指定なので連続で押せる） |
| `prefix` → `Ctrl+n` / `Ctrl+p` | 次 / 前のウィンドウへ（`Ctrl-a`を離さず`n/p`でも可） |
| `prefix` → `Tab` | 直前にいたウィンドウへトグルで戻る |
| `prefix` → `0`〜`9` | 番号でウィンドウへ直接切り替え（tmux標準機能） |
| `prefix` → `w` | ウィンドウ一覧を表示して選択 |

※ macのOptionキーは既定でAlt/Meta信号を送らないため、`Alt+何か`系のキーバインドは使っていない。

### コピーモード（vim風、クリップボード連携）

| キー | 動作 |
|---|---|
| `prefix` → `[` または `Escape` | コピーモード開始 |
| `h`/`j`/`k`/`l`, `w`/`b`, `gg`/`G` | vimと同じカーソル移動 |
| `v` | 選択開始（Visual） |
| `V` | 行選択 |
| `Ctrl-v` | 矩形選択 |
| `y` または `Enter` | コピーして **macOSのクリップボードへ**（`pbcopy`連携） |
| マウスドラッグ | ドラッグ終了時に自動でクリップボードへコピー |
| `prefix` → `p` | 貼り付け |
| 右クリック | **prefix不要**で貼り付け |

### その他

| キー | 動作 |
|---|---|
| `prefix` → `b` | 全pane同時入力（ブロードキャスト）のON/OFF切り替え |
| `prefix` → `r` | `tmux.conf` をリロード |
| マウス | クリックでpane選択、ドラッグでリサイズ、ホイールでスクロール |

各paneの上端に常時ラベル（`pane番号 実行中コマンド`）を表示。アクティブなpaneは枠が青太字になるので、今どこにいるかが一目で分かる。

## カラーパレット

`tmux.conf` 冒頭で端末背景 + Tokyo Night accent の色を `%hidden` 変数として定義し、以降 `$BLUE` のような名前で使っている。配色を変えたい場合はここだけ書き換えれば全体に反映される。

背景は `BG="default"` にしてあるため、Ghostty の `background-opacity` / blur や、ほかの端末アプリのテーマ背景が tmux の pane / status にそのまま通る。端末ごとに背景色を合わせたい場合も、tmux 側で色を固定せず端末側のテーマを変えるだけでよい。

```
%hidden BG="default"      端末アプリのデフォルト背景
%hidden FG="#a9b1d6"      通常文字
%hidden ACCENT_FG="#1a1b26" アクセント背景上の文字
%hidden DIM="#565f89"     非アクティブ/枠線など
%hidden SEP="#414868"     区切り
%hidden BLUE="#7aa2f7"    セッション名・時計
%hidden CYAN="#7dcfff"    CPU・日付
%hidden PURPLE="#bb9af7"  Network
%hidden GREEN="#9ece6a"   Visualモード・下り速度・バッテリー高
%hidden YELLOW="#e0af68"  バッテリー中
%hidden RED="#f7768e"     Prefixモード・上り速度・バッテリー低
```

## 既知の注意点

- `net_speed.sh` はキャッシュを `${TMPDIR}/tmux_net_<インターフェース名>` に保存し、複数クライアントが同時にアタッチしても壊れないよう一時ファイル→rename の原子的書き込みにしてある。
- `#(...)` で呼ぶ外部コマンドはtmuxのジョブ機構により**クライアントがアタッチしている時だけ**評価される。デタッチ状態で `tmux display-message` 等から値を覗いても空になるのは仕様（バグではない）。
- `net_speed.sh` / `cpu.sh` / `battery.sh` は macOS (Darwin) と Linux の両方で動くよう `uname -s` で分岐している（macOS: `route`/`netstat`/`sysctl`/`pmset`、Linux: `ip route`/`/sys/class/net/*/statistics`/`/proc/loadavg`/`/sys/class/power_supply/BAT*`）。バッテリーが無い環境（Linuxのデスクトップ等）ではBattery表示自体が出ないのが仕様。
- `net_speed.sh` / `cpu.sh` / `mem.sh` / `battery.sh` はいずれも `${TMPDIR}/tmux_*_out` に直近の描画結果を1秒(`MIN_INTERVAL`)キャッシュし、それより高頻度に呼ばれた場合は外部コマンド（`top`/`netstat`/`vm_stat`/`pmset`等）を一切起動せずキャッシュをそのまま返す。tmuxは「status-intervalごとにしか`#()`jobを呼ばない」わけではなく、paneに出力があるたびにも再描画して`#()`jobを再実行するため、Claude Codeが動いている（＝paneが出力し続けている）間はこれらのスクリプトが実測で1秒間に数十回呼ばれることがあり、キャッシュ無しだと外部コマンドが積み上がって負荷になったり（特に`top`は1回数百ms掛かるため多重実行されやすい）、差分計算系の値（旧`net_speed.sh`）が不安定になったりする。ステータスバーの値がガタつく/重いと感じたら、まずこのキャッシュ層が意図通り効いているかを疑う。

