---
name: update-dotfile-readme
description: Use when a new tool's config directory is added under .config/ (or an existing one's setup changes) in this dotfiles repo, to keep the root README.md in sync — its 構成 table and per-tool symlink setup instructions.
---

# README更新（ドットファイル追加時）

このリポジトリ（datfile）はツールごとの設定を `.config/<ツール名>/` に置き、
`ln -s` でホームディレクトリに配置する方式のdotfiles管理をしている。
新しい `.config/<ツール名>/` が追加された、または既存の配置手順が変わったときは、
ルートの `README.md` を以下の手順で更新する。

## 手順

1. `.config/` 配下で `README.md` にまだ載っていないディレクトリがないか確認する
   （`git status` の untracked / 新規追加された `.config/*` を見る）。
2. 「構成」テーブルに1行追加する。
   - そのツール自体に `.config/<ツール名>/README.md` があればリンクする。
   - なければ何の設定か一言で説明する。
3. 「セットアップ」内に、既存の tmux / nvim セクションと同じ形式で
   `### <ツール名>設定の配置` セクションを追加する。既存パターンを踏襲する：

   ```bash
   # 既存設定があれば退避（無ければ何もしない）
   [ -e ~/.config/<ツール名> ] && mv ~/.config/<ツール名> ~/.config/<ツール名>.bak

   mkdir -p ~/.config
   ln -s ~/codes/datfile/.config/<ツール名> ~/.config/<ツール名>
   ```

   - 設定ファイルが `~/.config/` 以外（例: `~/.zshrc` のような単一ファイル）に
     配置される種類のものは、対象パスに合わせて `ln -s` の行き先を調整する。
   - そのツール固有の反映確認コマンドがあれば（tmuxの `tmux source-file` のように）続けて書く。
4. 末尾の「設定を追加する場合」セクションは以後の追加分に対する一般的な手順なので、
   内容は変えず末尾に留める（各ツール専用セクションはその手前に追加する）。
5. 更新後、`README.md` の構成テーブルと実際の `.config/` の中身が一致しているか見直す。
