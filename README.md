# datfile

個人用の設定ファイル（dotfiles）を管理するリポジトリ。

## 構成

| パス | 内容 |
|---|---|
| `.config/tmux/` | tmux設定。詳細は [.config/tmux/README.md](.config/tmux/README.md) 参照 |
| `.config/nvim/` | Neovim設定（[LazyVim](https://github.com/LazyVim/LazyVim)ベース） |

## セットアップ

このリポジトリを任意の場所にクローンし、各設定をシンボリックリンクで `$HOME` 配下に配置する。

```bash
git clone https://github.com/yumekiti/datfile ~/codes/datfile
```

### tmux設定の配置

既存の `~/.config/tmux` がある場合は退避してからリンクを張る。

```bash
# 既存設定があれば退避（無ければ何もしない）
[ -e ~/.config/tmux ] && mv ~/.config/tmux ~/.config/tmux.bak

mkdir -p ~/.config
ln -s ~/codes/datfile/.config/tmux ~/.config/tmux
```

反映確認:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

### nvim設定の配置

既存の `~/.config/nvim` がある場合は退避してからリンクを張る。

```bash
# 既存設定があれば退避（無ければ何もしない）
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

mkdir -p ~/.config
ln -s ~/codes/datfile/.config/nvim ~/.config/nvim
```

[LazyVim](https://github.com/LazyVim/LazyVim)ベースのため、初回起動時にプラグインが自動インストールされる。

### 設定を追加する場合

新しい設定を追加したら、同様に `.config/<ツール名>` としてこのリポジトリに置き、`ln -s ~/codes/datfile/.config/<ツール名> ~/.config/<ツール名>` でリンクする。編集はリポジトリ側のファイルに対して行えばよく（シンボリックリンク経由のため）、変更はそのまま `git status` / `git diff` で追跡できる。
