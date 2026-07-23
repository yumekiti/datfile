# 💤 LazyVim (カスタム設定)

[LazyVim](https://github.com/LazyVim/LazyVim) ベースの設定。VSCodeに近い使用感を目指して、デバッガ・パンくずリスト・マルチカーソル・見慣れたキーバインドを追加している。

## カスタム内容

- **透過背景**: tmux(`../tmux/tmux.conf`のBG="default")と同じく、端末の背景色をそのまま透過させる(`lua/plugins/colorscheme.lua`)
- **デバッグ(DAP)**: `nvim-dap` + `nvim-dap-ui`。言語ごとのデバッガは別途lang extraを有効にすると自動設定される
- **パンくずリスト**: `nvim-navic`。ステータスラインに現在のシンボル階層(クラス/関数など)を表示
- **マルチカーソル**: `mg979/vim-visual-multi`。VSCodeのCmd+D相当は `Ctrl-n`
- **VSCode風キーバインド**: `Ctrl-p` / `Ctrl-Shift-p` / `Ctrl-b`(下記参照)
- **Git管理(lazygit)**: `brew install lazygit` するとLazyVim標準の `<leader>gg` が自動で有効になる(設定不要)
- **Markdown**: `render-markdown.nvim`で箇条書き・コードブロックをリッチ表示。`markdownlint`(MD013など)は無効化、フォーマットは`prettier`のみ、LSPは`marksman`(`lua/plugins/markdown.lua`)。日本語/専門用語で誤検知が多いため`spell`もmarkdownでは無効化(`lua/config/autocmds.lua`)

## 操作方法

### ファイル一覧(エクスプローラー)を開く・戻る

| キー | 動作 |
|---|---|
| `Ctrl-b` / `<leader>e` | エクスプローラーを開く・閉じる(トグル) |
| `Ctrl-w h` | (ファイルを開いてカーソルが移った後)左のエクスプローラーへ戻る |
| `Ctrl-w Ctrl-w` | 開いているウィンドウを順番に切り替え |

### エクスプローラー内の操作

| キー | 動作 |
|---|---|
| `Enter` / `l` | ファイルを開く・ディレクトリを開く |
| `h` | ディレクトリを閉じる |
| `Backspace` | 1つ上の階層へ |
| `a` | 新規ファイル/ディレクトリ作成(末尾 `/` でディレクトリ) |
| `d` | 削除(ゴミ箱に移動) |
| `r` | リネーム |
| `Tab` | 複数選択 → `m` で移動、`c` でコピー |
| `y` / `p` | ヤンク / ペースト(コピー) |
| `H` | 隠しファイル表示切替 |
| `.` | このディレクトリをcwdにする |
| `q` / `Esc` | 閉じる |

### ファイル検索・移動

| キー | 動作 |
|---|---|
| `Ctrl-p` / `<leader>ff` | ファイル名であいまい検索(選ぶと一覧は閉じる) |
| `<leader>fr` | 最近使ったファイル |
| `Ctrl-Shift-p` / `<leader>sC` | コマンドパレット |
| `<leader><space>` | ファイル検索(別バインド) |

### バッファ(開いているファイル・画面上部のタブ)の切り替え

「タブ移動」で普段使うのはこっち(vimの`:tabnew`とは別物)。

| キー | 動作 |
|---|---|
| `<S-h>` / `<S-l>` | 前・次のバッファ |
| `[b` / `]b` | 前・次のバッファ(同じ) |
| `<leader>bd` | 現在のバッファを閉じる |
| `<leader>,` | バッファ一覧から選択 |

### vimのタブページ(ウィンドウレイアウトごとのタブ、あまり使わない)

| キー | 動作 |
|---|---|
| `<leader><tab><tab>` | 新規タブ |
| `<leader><tab>]` / `<leader><tab>[` | 次・前のタブ |
| `<leader><tab>f` / `<leader><tab>l` | 最初・最後のタブ |
| `<leader><tab>d` | タブを閉じる |
| `<leader><tab>o` | 他のタブを全部閉じる |

### 分割・ウィンドウ

| キー | 動作 |
|---|---|
| `Ctrl-w s` / `Ctrl-w v` | 水平/垂直分割 |
| `Ctrl-h/j/k/l` | 分割間の移動 |
| `Ctrl-/` | ターミナルをトグル |

### デバッグ

| キー | 動作 |
|---|---|
| `<leader>db` | ブレークポイント切替 |
| `<leader>dc` | 実行 / 続行 |
| `<leader>du` | デバッグUIを開く |
| `<leader>di` / `<leader>do` / `<leader>dO` | ステップイン / アウト / オーバー |

### マルチカーソル

| キー | 動作 |
|---|---|
| `Ctrl-n` | カーソル下の単語を選択、押すたびに次の一致へ拡張(VSCodeのCmd+D相当) |

### Git管理(lazygit)

VSCodeのソース管理パネルに近いUI。ステージ済み/未ステージの差分を並べて表示し、そのままコミット・push/pullまでできる。`brew install lazygit`していれば自動で有効(未インストールだとキー自体が登録されない)。

| キー | 動作 |
|---|---|
| `<leader>gg` | lazygitを開く(リポジトリルート) |
| `<leader>gG` | lazygitを開く(カレントディレクトリ) |

lazygit内では: `Space`でステージ/アンステージ、`c`でコミット、`P`でpush、`p`でpull、`Esc`/`q`で閉じる。

### 終了

| キー | 動作 |
|---|---|
| `<leader>qq` | 全部まとめて終了(`:qa`と同じ、未保存があれば確認) |
| `ZZ` | 保存して終了(コロン不要) |
| `:wqa` | 全部保存してから終了 |
| `:qa!` | 保存せず強制終了 |

### 困ったら

`<leader>` を押して少し待つと which-key が候補一覧を出すので、そこから探すのが早い。
