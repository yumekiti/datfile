#!/usr/bin/env bash
# CPU使用率(%)を色付きで出す（tmux設定内でのクォート崩れを避けるため別ファイル化）
#
# Linuxは/proc/statの前回サンプルとの差分から算出。net_speed.shと同じく
# キャッシュは「一時ファイルに書いてからrename」で原子的に更新する。
#
# 呼び出し自体を MIN_INTERVAL 秒に間引く（詳細は net_speed.sh のコメント参照）。
# これが無いと、Claude Codeがpaneに出力し続けている間はこのスクリプトが
# 1秒間に何度も再実行され、macOSでは `top -l 1`（1回あたり数百ms）が
# 積み上がって多重実行される（測定自体がCPU負荷を生む自己参照的な悪化）。
# Linuxの差分計算も dt がほぼ0になり値が不安定になる、net_speed.shで
# 実際に踏んだのと同種の不具合を踏む。

MIN_INTERVAL=1
OUT_CACHE="${TMPDIR:-/tmp}/tmux_cpu_out"
now=$(date +%s)

if [ -r "$OUT_CACHE" ]; then
  { IFS= read -r c_ts; IFS= read -r c_out; } < "$OUT_CACHE" 2>/dev/null
  case "$c_ts" in
    *[!0-9]*|'') ;;
    *) [ $(( now - c_ts )) -lt "$MIN_INTERVAL" ] && { printf '%s' "$c_out"; exit 0; } ;;
  esac
fi

if [ "$(uname -s)" = "Darwin" ]; then
  pct=$(top -l 1 -n 0 2>/dev/null | awk -F'[:,]' '/CPU usage/{gsub(/[ %]/,"",$4); print 100-$4}')
else
  CACHE="${TMPDIR:-/tmp}/tmux_cpu_stat"
  read -r _ u1 n1 s1 i1 w1 q1 sq1 rest < /proc/stat

  p_u="" p_n="" p_s="" p_i="" p_w="" p_q="" p_sq=""
  [ -r "$CACHE" ] && read -r p_u p_n p_s p_i p_w p_q p_sq < "$CACHE" 2>/dev/null

  tmpfile="${CACHE}.tmp.$$"
  printf '%s %s %s %s %s %s %s\n' "$u1" "$n1" "$s1" "$i1" "$w1" "$q1" "$sq1" > "$tmpfile" && mv -f "$tmpfile" "$CACHE"

  case "$p_u $p_n $p_s $p_i $p_w $p_q $p_sq" in
    *[!0-9\ ]*|"       ") p_u=$u1; p_n=$n1; p_s=$s1; p_i=$i1; p_w=$w1; p_q=$q1; p_sq=$sq1 ;;
  esac

  idle_prev=$(( p_i + p_w ))
  idle_now=$(( i1 + w1 ))
  total_prev=$(( p_u + p_n + p_s + p_i + p_w + p_q + p_sq ))
  total_now=$(( u1 + n1 + s1 + i1 + w1 + q1 + sq1 ))

  dtotal=$(( total_now - total_prev ))
  didle=$(( idle_now - idle_prev ))

  if [ "$dtotal" -gt 0 ]; then
    pct=$(( (100 * (dtotal - didle)) / dtotal ))
  else
    pct=0
  fi
fi

[ -z "$pct" ] && pct=0
pct=${pct%.*}
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
