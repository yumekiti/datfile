# datfile

個人用の設定ファイル（dotfiles）を管理するリポジトリ。

## 構成

| パス | 内容 |
|---|---|
| `.config/tmux/` | tmux設定。詳細は [.config/tmux/README.md](.config/tmux/README.md) 参照 |
| `.config/nvim/` | Neovim設定（[LazyVim](https://github.com/LazyVim/LazyVim)ベース） |
| `.ssh/config` | SSHのホスト別設定 |
| `.config/bash/init.sh` | `ls`/`l`/`cat`/`c`/`vi` を `eza`/`bat`（ページャなし）/`nvim` に置き換えるエイリアス/関数。`vi`はgitリポジトリ内かつ[difit](https://github.com/yoshiko-pg/difit)がインストール済みなら、nvim起動中だけdifitをバックグラウンドで併走させる（nvim終了で自動kill）。`dif` を difit のエイリアスとして登録。[zoxide](https://github.com/ajeetdsouza/zoxide)で`cd`を拡張する初期化。`~/.bash_profile` から読み込む |

## セットアップ

このリポジトリを任意の場所にクローンし、各設定をシンボリックリンクで `$HOME` 配下に配置する。

```bash
git clone git@github.com:yumekiti/datfile.git ~/codes/datfile
```

### Homebrewでインストールするもの

このリポジトリの設定が利用するツールのうち、Homebrewで入れるものをまとめておく。

| パッケージ | 用途 | 必須/任意 |
|---|---|---|
| [eza](https://github.com/eza-community/eza) | `ls`/`l`エイリアス（後述の「bash設定（eza/bat/zoxide）の配置」） | 必須（bash設定を使う場合） |
| [bat](https://github.com/sharkdp/bat) | `cat`/`c`エイリアス（後述の「bash設定（eza/bat/zoxide）の配置」） | 必須（bash設定を使う場合） |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd`でのディレクトリジャンプ（後述の「bash設定（eza/bat/zoxide）の配置」） | 必須（bash設定を使う場合） |
| [lazygit](https://github.com/jesseduffield/lazygit) | nvimのGit管理パネル（`<leader>gg`、[.config/nvim/README.md](.config/nvim/README.md)参照） | 任意（未インストールでもキー自体が登録されないだけ） |
| [node](https://formulae.brew.sh/formula/node) | 後述の「npmでインストールするもの」の`npm`コマンドを提供 | 任意（difitを使う場合のみ必須） |

```bash
brew install eza bat zoxide lazygit node
```

### npmでインストールするもの

nodeに付属する`npm`で入れるものをまとめておく。事前に上記の`node`をインストールしておくこと。

| パッケージ | 用途 | 必須/任意 |
|---|---|---|
| [difit](https://github.com/yoshiko-pg/difit) | `dif`エイリアスで使うdiffビューア（後述の「bash設定（eza/bat/zoxide）の配置」） | 任意（未インストールでも`dif`コマンドが動かないだけ） |

```bash
npm install -g difit
```

### tmux設定の配置

既存の `~/.config/tmux` は上書きしてリンクを張る。

```bash
rm -rf ~/.config/tmux
mkdir -p ~/.config
ln -s ~/codes/datfile/.config/tmux ~/.config/tmux
```

起動確認:

```bash
tmux
```

新規セッション開始時に自動でこの設定が読み込まれる。すでにセッションを起動済みで設定だけ
反映したい場合は、以下のいずれかで反映する。

- セッション内で `prefix → r`
- またはセッション内のシェルで `tmux source-file ~/.config/tmux/tmux.conf`
  （tmuxサーバー未起動の状態でこれを実行すると `error connecting to /tmp/tmux-0/default`
  になるだけなので、その場合は上の「起動」を先に行う）
- それでも変更が反映されない場合（配色変数など一部の設定は既存セッションに残ったままに
  なることがある）は、一度サーバーごと落として起動し直す。

  ```bash
  tmux kill-server
  tmux
  ```

  **`kill-server` は起動中の全tmuxセッションを終了する**（各pane内のプロセスも終了する）
  ので、実行前に必要な作業を保存しておくこと。

### nvim設定の配置

既存の `~/.config/nvim` は上書きしてリンクを張る。

```bash
rm -rf ~/.config/nvim
mkdir -p ~/.config
ln -s ~/codes/datfile/.config/nvim ~/.config/nvim
```

[LazyVim](https://github.com/LazyVim/LazyVim)ベースのため、初回起動時にプラグインが自動インストールされる。

### ssh設定の配置

既存の `~/.ssh/config` は上書きしてリンクを張る。

```bash
rm -f ~/.ssh/config
mkdir -p ~/.ssh
ln -s ~/codes/datfile/.ssh/config ~/.ssh/config
```

### bash設定（eza/bat/zoxide）の配置

`.config/bash/` は専用ディレクトリなので既存のものがあれば上書きしてリンクを張る。

```bash
rm -rf ~/.config/bash
mkdir -p ~/.config
ln -s ~/codes/datfile/.config/bash ~/.config/bash
```

`~/.bash_profile` は既存の内容を保ったまま、読み込み行がなければ追記する
（すでにある場合は二重追記しない）。

```bash
grep -qxF 'source ~/.config/bash/init.sh' ~/.bash_profile 2>/dev/null || \
  echo 'source ~/.config/bash/init.sh' >> ~/.bash_profile
source ~/.bash_profile
```

前述の「Homebrewでインストールするもの」の`eza`/`bat`/`zoxide`を事前にインストールしておく。

新規ターミナルを開くと自動で読み込まれる。すでに開いているシェルに反映したい場合は
`source ~/.bash_profile` を実行する。反映後は `ls`/`cat`/`c`/`vi` が `eza`/`bat`（ページャなし）/`nvim` の
エイリアスとして動作し、`cd <キーワード>` でzoxideによるディレクトリジャンプができる。

### 設定を追加する場合

このリポジトリは `$HOME` のディレクトリ構造をそのまま再現している（`.config/tmux/` → `~/.config/tmux`、`.ssh/config` → `~/.ssh/config` のように、リポジトリ内のパスとホーム側の配置先が1:1で対応する）。新しい設定を追加する場合も、`$HOME` から見た相対パスと同じ場所にこのリポジトリ内へ置き、`ln -s ~/codes/datfile/<パス> ~/<同じパス>` でリンクする。編集はリポジトリ側のファイルに対して行えばよく（シンボリックリンク経由のため）、変更はそのまま `git status` / `git diff` で追跡できる。

