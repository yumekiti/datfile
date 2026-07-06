#!/usr/bin/env bash
# CPU負荷(load average, 1分値)を固定幅で出す（tmux設定内でのクォート崩れを避けるため別ファイル化）

load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2}')
[ -z "$load" ] && load="0.00"

printf '%5.2f' "$load"
