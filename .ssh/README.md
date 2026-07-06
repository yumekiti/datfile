# ssh設定

ホスト別のSSH接続設定（`config`）のみを管理する。秘密鍵はこのリポジトリには含めない。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `config` | ホスト別のSSH接続設定（`Host *` の共通設定 + ホストごとのエイリアス） |

## 鍵の登録

`config` の `ForwardAgent yes` はssh-agentに登録済みの鍵をエージェント転送する設定。
接続前にagentへ鍵が登録されているか確認する。

```bash
ssh-add -L
```

`The agent has no identities.` と出た場合は鍵が登録されていないので、以下で追加する。

```bash
ssh-add ~/.ssh/hogehoge
```

`hogehoge` は実際の秘密鍵ファイル名に置き換える（例: `id_ed25519`）。秘密鍵自体は
リポジトリで管理せず、各マシンの `~/.ssh/` に個別に置く。
