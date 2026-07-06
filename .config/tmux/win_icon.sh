#!/usr/bin/env bash
# 実行中コマンド名 → アイコン+ラベルに変換（tmuxウィンドウ表示用）
# シェルがアイドルなだけの時は無地アイコンのみ（"bash"などの生文字列を出さない）

cmd="$1"

case "$cmd" in
  bash|zsh|fish|sh|tmux) printf '' ;;                       # ただのシェル：アイコンのみ
  vim|nvim)              printf ' vim' ;;
  node)                  printf ' node' ;;
  python|python3|ipython) printf ' python' ;;
  git)                    printf ' git' ;;
  ssh)                    printf ' ssh' ;;
  docker|docker-compose)  printf ' docker' ;;
  man|less|more)          printf ' man' ;;
  top|htop|btm)           printf ' top' ;;
  psql|mysql|sqlite3)     printf ' sql' ;;
  npm|yarn|pnpm)          printf ' pkg' ;;
  cargo|rustc)            printf ' rust' ;;
  go)                     printf ' go' ;;
  claude)                 printf ' claude' ;;
  "")                     printf '' ;;
  *)                      printf ' %s' "$cmd" ;;
esac
