# datfile

個人用の設定ファイル（dotfiles）を管理するリポジトリ。

## 構成

| パス | 内容 |
|---|---|
| `.config/tmux/` | tmux設定。詳細は [.config/tmux/README.md](.config/tmux/README.md) 参照 |
| `.config/nvim/` | Neovim設定（[LazyVim](https://github.com/LazyVim/LazyVim)ベース） |
| `.ssh/config` | SSHのホスト別設定 |

## セットアップ

このリポジトリを任意の場所にクローンし、各設定をシンボリックリンクで `$HOME` 配下に配置する。

```bash
git clone git@github.com:yumekiti/datfile.git ~/codes/datfile
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

### 設定を追加する場合

このリポジトリは `$HOME` のディレクトリ構造をそのまま再現している（`.config/tmux/` → `~/.config/tmux`、`.ssh/config` → `~/.ssh/config` のように、リポジトリ内のパスとホーム側の配置先が1:1で対応する）。新しい設定を追加する場合も、`$HOME` から見た相対パスと同じ場所にこのリポジトリ内へ置き、`ln -s ~/codes/datfile/<パス> ~/<同じパス>` でリンクする。編集はリポジトリ側のファイルに対して行えばよく（シンボリックリンク経由のため）、変更はそのまま `git status` / `git diff` で追跡できる。
