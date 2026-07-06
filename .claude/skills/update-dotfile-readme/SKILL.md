---
name: update-dotfile-readme
description: Use when a new dotfile/config is added anywhere in this repo (not just under .config/ — e.g. .ssh/config, .zshrc) or an existing one's setup changes, to keep the root README.md in sync — its 構成 table and per-path symlink setup instructions.
---

# README更新（ドットファイル追加時）

このリポジトリ（datfile）は `$HOME` のディレクトリ構造をそのままリポジトリ直下に
再現し（例: `.config/tmux/`, `.config/nvim/`, `.ssh/config`）、`ln -s` で
ホームディレクトリに配置する方式のdotfiles管理をしている。**`.config/` 配下に限らず、
リポジトリのどこに新しいパスが増えても対象になる。**
新しいファイル/ディレクトリが追加された、または既存の配置手順が変わったときは、
ルートの `README.md` を以下の手順で更新する。

## 手順

1. リポジトリルート直下を機械的に列挙し、`README.md` の構成テーブルに
   まだ載っていないものがないか確認する。

   ```bash
   ls -a ~/codes/datfile | grep '^\.' | grep -v -E '^(\.|\.\.|\.git|\.claude)$'
   ```

   - 特定の既知のパス（`.config`、`.ssh`など）だけを個別に思い出すのではなく、
     このコマンドで出てきたトップレベルの `.`から始まる項目を毎回すべて洗い出す。
   - `.git`（リポジトリ管理用）と `.claude`（Claude Code自体の設定・スキル置き場）は
     `$HOME` に配置する対象ではないため除外する。
   - ディレクトリの場合はさらに中身も見て、テーブルに載っている粒度
     （ツール単位のディレクトリか、個別ファイルか）まで掘り下げる。
2. 「構成」テーブルに1行追加する。パスはリポジトリルートからの相対パス
   （例: `.config/tmux/`, `.ssh/config`）で書く。
   - そのパス自体に `README.md` があればリンクする。
   - なければ何の設定か一言で説明する。
3. 「セットアップ」内に、既存セクションと同じ形式で `### <対象>の配置` セクションを
   追加する。対象がディレクトリかファイルかで `$HOME` 側の対応パスが変わる点に注意し、
   実際のリポジトリ内パスとホーム側の配置先パスを1:1で対応させる：

   ```bash
   rm -rf ~/<ホーム側の対応パス>
   mkdir -p ~/<親ディレクトリ>
   ln -s ~/codes/datfile/<リポジトリ内パス> ~/<ホーム側の対応パス>
   ```

   既存設定は退避せず上書きする方針（このリポジトリでの合意）。対象が単一ファイルの場合は
   `rm -rf` の代わりに `rm -f` を使う。

   例: `.config/tmux/` → `~/.config/tmux`、`.ssh/config` → `~/.ssh/config`
   （後者は親ディレクトリが `~/.ssh` になるだけでディレクトリ/ファイルの違い以外は同じ形式）。
   - その設定固有の反映確認コマンドがあれば（tmuxの `tmux source-file` のように）続けて書く。
4. 末尾の「設定を追加する場合」セクションは以後の追加分に対する一般的な手順なので、
   内容は変えず末尾に留める（各設定専用セクションはその手前に追加する）。
5. 更新後、`README.md` の構成テーブルと実際のリポジトリの中身（`.config/` 以外も含む）が
   一致しているか見直す。
