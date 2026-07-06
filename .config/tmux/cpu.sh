#!/usr/bin/env bash
# CPU負荷(load average, 1分値)を固定幅で出す（tmux設定内でのクォート崩れを避けるため別ファイル化）

if [ "$(uname -s)" = "Darwin" ]; then
  load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
else
  load=$(awk '{print $1}' /proc/loadavg 2>/dev/null)
fi
[ -z "$load" ] && load="0.00"

printf '%5.2f' "$load"
