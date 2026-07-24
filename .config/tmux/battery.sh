#!/usr/bin/env bash
# バッテリー残量を「文字ブロックのバー」で出す（特殊フォント不要、どの環境でも確実に表示される）
#
# バー文字に "#" は使わない: tmuxはジョブ(#())の出力も自身のフォーマット文字列
# パーサーに通すため、連続した "#" が壊れて消える（"=" ならtmux側で特別扱いされない）。
#
# 呼び出し自体を MIN_INTERVAL 秒に間引く（詳細は net_speed.sh / cpu.sh のコメント参照）。
# Claude Codeがpaneに出力し続けている間はこのスクリプトも1秒間に何度も
# 再実行されるため、pmset起動自体を間引いて無駄なプロセス生成を防ぐ。

MIN_INTERVAL=1
OUT_CACHE="${TMPDIR:-/tmp}/tmux_battery_out"
now=$(date +%s)

if [ -r "$OUT_CACHE" ]; then
  { IFS= read -r c_ts; IFS= read -r c_out; } < "$OUT_CACHE" 2>/dev/null
  case "$c_ts" in
    *[!0-9]*|'') ;;
    *) [ $(( now - c_ts )) -lt "$MIN_INTERVAL" ] && { printf '%s' "$c_out"; exit 0; } ;;
  esac
fi

if [ "$(uname -s)" = "Darwin" ]; then
  info=$(pmset -g batt 2>/dev/null) || exit 0
  pct=$(printf '%s' "$info" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
  [ -z "$pct" ] && exit 0

  charging=0
  printf '%s' "$info" | grep -qE 'AC attached|charging' && charging=1
  printf '%s' "$info" | grep -q 'discharging' && charging=0
else
  batt=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
  [ -z "$batt" ] && exit 0

  pct=$(cat "$batt/capacity" 2>/dev/null)
  [ -z "$pct" ] && exit 0

  status=$(cat "$batt/status" 2>/dev/null)
  charging=0
  [ "$status" = "Charging" ] || [ "$status" = "Full" ] && charging=1
fi

filled=$(( (pct * 6 + 50) / 100 ))
[ "$filled" -gt 6 ] && filled=6
[ "$filled" -lt 0 ] && filled=0
empty=$(( 6 - filled ))

bar=""
for ((i = 0; i < filled; i++)); do bar+="="; done
for ((i = 0; i < empty; i++)); do bar+="-"; done

if   [ "$pct" -ge 60 ]; then color="#9ece6a"
elif [ "$pct" -ge 30 ]; then color="#e0af68"
else                          color="#f7768e"
fi

suffix="% "
[ "$charging" -eq 1 ] && suffix="%+"

out=$(printf '#[fg=%s][%s]%3d%s' "$color" "$bar" "$pct" "$suffix")

tmpfile="${OUT_CACHE}.tmp.$$"
{ printf '%s\n' "$now"; printf '%s\n' "$out"; } > "$tmpfile" 2>/dev/null && mv -f "$tmpfile" "$OUT_CACHE"

printf '%s' "$out"
