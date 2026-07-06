#!/usr/bin/env bash
# ネットワークの上り/下り瞬間速度を色付きで1発出力する（tmux status-right用）
#
# 前回サンプルとの差分から速度を算出。キャッシュへの書き込みは
# 「一時ファイルに書いてから rename」で原子的に行う（= 複数のtmuxクライアント/paneが
# 同時に読み書きしても、書きかけの壊れた行を掴んで変な値になるのを防ぐ）。
# 数値部分は幅を固定しているので、桁数が変わってもステータスバー全体がガタつかない。

IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
[ -z "$IFACE" ] && IFACE="en0"

CACHE="${TMPDIR:-/tmp}/tmux_net_${IFACE}"

read -r rx tx < <(netstat -ibn 2>/dev/null | awk -v i="$IFACE" '$1==i{print $7, $10; exit}')
now=$(date +%s)

if [ -z "$rx" ] || [ -z "$tx" ]; then
  printf '#[fg=#565f89]   no net'
  exit 0
fi

p_now="" p_rx="" p_tx=""
[ -r "$CACHE" ] && read -r p_now p_rx p_tx < "$CACHE" 2>/dev/null

# キャッシュが壊れている/数値でない場合は今回値で仕切り直す（誤動作防止）
case "$p_now $p_rx $p_tx" in
  *[!0-9\ ]*|"  ") p_now=$now; p_rx=$rx; p_tx=$tx ;;
esac

tmpfile="${CACHE}.tmp.$$"
printf '%s %s %s\n' "$now" "$rx" "$tx" > "$tmpfile" && mv -f "$tmpfile" "$CACHE"

dt=$(( now - p_now )); [ "$dt" -le 0 ] && dt=1
drx=$(( (rx - p_rx) / dt )); [ "$drx" -lt 0 ] && drx=0
dtx=$(( (tx - p_tx) / dt )); [ "$dtx" -lt 0 ] && dtx=0

# 物理的にあり得ない値（回線切替やカウンタ異常）は弾く
[ "$drx" -gt 1250000000 ] && drx=0
[ "$dtx" -gt 1250000000 ] && dtx=0

fmt() {
  awk -v b="$1" 'BEGIN{
    split("B K M G", u, " ");
    i=1; v=b;
    while (v>=1024 && i<4){ v/=1024; i++ }
    if (i==1) printf "%4d%s", v, u[i];
    else      printf "%4.1f%s", v, u[i];
  }'
}

printf '#[fg=#9ece6a]↓%s #[fg=#f7768e]↑%s' "$(fmt "$drx")" "$(fmt "$dtx")"
