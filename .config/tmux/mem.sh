#!/usr/bin/env bash
# メモリ使用率(%)を色付きで出す（tmux設定内でのクォート崩れを避けるため別ファイル化）
#
# 呼び出し自体を MIN_INTERVAL 秒に間引く（詳細は net_speed.sh / cpu.sh のコメント参照）。
# Claude Codeがpaneに出力し続けている間はこのスクリプトも1秒間に何度も
# 再実行されるため、vm_stat/sysctlの起動自体を間引いて無駄なプロセス生成を防ぐ。

MIN_INTERVAL=1
OUT_CACHE="${TMPDIR:-/tmp}/tmux_mem_out"
now=$(date +%s)

if [ -r "$OUT_CACHE" ]; then
  { IFS= read -r c_ts; IFS= read -r c_out; } < "$OUT_CACHE" 2>/dev/null
  case "$c_ts" in
    *[!0-9]*|'') ;;
    *) [ $(( now - c_ts )) -lt "$MIN_INTERVAL" ] && { printf '%s' "$c_out"; exit 0; } ;;
  esac
fi

if [ "$(uname -s)" = "Darwin" ]; then
  vmstat=$(vm_stat 2>/dev/null)
  page_size=$(sysctl -n hw.pagesize 2>/dev/null)
  [ -z "$page_size" ] && page_size=4096

  active=$(printf '%s\n' "$vmstat" | awk '/Pages active:/{gsub("\\.","",$NF); print $NF}')
  wired=$(printf '%s\n' "$vmstat" | awk '/Pages wired down:/{gsub("\\.","",$NF); print $NF}')
  compressed=$(printf '%s\n' "$vmstat" | awk '/Pages occupied by compressor:/{gsub("\\.","",$NF); print $NF}')
  total_mem=$(sysctl -n hw.memsize 2>/dev/null)

  active=${active:-0}; wired=${wired:-0}; compressed=${compressed:-0}
  used_bytes=$(( (active + wired + compressed) * page_size ))

  if [ -n "$total_mem" ] && [ "$total_mem" -gt 0 ]; then
    pct=$(( used_bytes * 100 / total_mem ))
  else
    pct=0
  fi
else
  read -r total avail < <(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print t, a}' /proc/meminfo)
  if [ -n "$total" ] && [ "$total" -gt 0 ]; then
    pct=$(( (total - avail) * 100 / total ))
  else
    pct=0
  fi
fi

[ "$pct" -lt 0 ] 2>/dev/null && pct=0
[ "$pct" -gt 100 ] 2>/dev/null && pct=100

if   [ "$pct" -ge 80 ]; then color="#f7768e"
elif [ "$pct" -ge 50 ]; then color="#e0af68"
else                          color="#9ece6a"
fi

out=$(printf '#[fg=%s]%3d%%' "$color" "$pct")

tmpfile="${OUT_CACHE}.tmp.$$"
{ printf '%s\n' "$now"; printf '%s\n' "$out"; } > "$tmpfile" 2>/dev/null && mv -f "$tmpfile" "$OUT_CACHE"

printf '%s' "$out"
