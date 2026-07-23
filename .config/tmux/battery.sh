#!/usr/bin/env bash
# バッテリー残量を「文字ブロックのバー」で出す（特殊フォント不要、どの環境でも確実に表示される）
#
# バー文字に "#" は使わない: tmuxはジョブ(#())の出力も自身のフォーマット文字列
# パーサーに通すため、連続した "#" が壊れて消える（"=" ならtmux側で特別扱いされない）。

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

printf '#[fg=%s][%s]%3d%s' "$color" "$bar" "$pct" "$suffix"
