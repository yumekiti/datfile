#!/usr/bin/env bash
# ネットワークの上り/下り瞬間速度を色付きで1発出力する（tmux status-right用）
#
# 前回サンプルとの差分から速度を算出。キャッシュへの書き込みは
# 「一時ファイルに書いてから rename」で原子的に行う（= 複数のtmuxクライアント/paneが
# 同時に読み書きしても、書きかけの壊れた行を掴んで変な値になるのを防ぐ）。
# 数値部分は幅を固定しているので、桁数が変わってもステータスバー全体がガタつかない。
#
# サンプリング間隔は最低 MIN_INTERVAL 秒を保証する（チェックポイントを自前で
# 間引く）。tmux通常は status-interval(2秒)ごとにしかこのスクリプトを呼ばないが、
# ai_thinking.sh の常駐スピナーが応答中 refresh-client -S を高頻度(0.3秒毎)に
# 叩くと、それに連動してこのジョブも同じ頻度で再実行されることがある。dt を
# date +%s の秒精度のまま使うと、1秒未満の間隔で連続実行された際にバイト差分が
# ほぼゼロなのに整数除算で 0B に丸められてしまう（実際に発生した不具合）。
# そのため直近の実測チェックポイントから MIN_INTERVAL 秒経つまでは新規計測を
# せず、前回算出済みのレートをそのまま使い回す。

if [ "$(uname -s)" = "Darwin" ]; then
  IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
  [ -z "$IFACE" ] && IFACE="en0"
else
  IFACE=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
fi

CACHE="${TMPDIR:-/tmp}/tmux_net_${IFACE}"
MIN_INTERVAL=1

if [ "$(uname -s)" = "Darwin" ]; then
  read -r rx tx < <(netstat -ibn 2>/dev/null | awk -v i="$IFACE" '$1==i{print $7, $10; exit}')
else
  rx=$(cat "/sys/class/net/${IFACE}/statistics/rx_bytes" 2>/dev/null)
  tx=$(cat "/sys/class/net/${IFACE}/statistics/tx_bytes" 2>/dev/null)
fi
now=$(date +%s)

if [ -z "$rx" ] || [ -z "$tx" ]; then
  printf '#[fg=#565f89]   no net'
  exit 0
fi

fmt() {
  awk -v b="$1" 'BEGIN{
    split("B K M G", u, " ");
    i=1; v=b;
    while (v>=1024 && i<4){ v/=1024; i++ }
    if (i==1) printf "%4d%s", v, u[i];
    else      printf "%4.1f%s", v, u[i];
  }'
}

p_now="" p_rx="" p_tx="" p_drx="" p_dtx=""
[ -r "$CACHE" ] && read -r p_now p_rx p_tx p_drx p_dtx < "$CACHE" 2>/dev/null

# キャッシュが壊れている/数値でない場合は今回値でチェックポイントを作り直す
# （誤動作防止）。この回はまだ差分を計算できないので0を出す。
case "$p_now $p_rx $p_tx $p_drx $p_dtx" in
  *[!0-9\ ]*|"    ")
    tmpfile="${CACHE}.tmp.$$"
    printf '%s %s %s %s %s\n' "$now" "$rx" "$tx" 0 0 > "$tmpfile" && mv -f "$tmpfile" "$CACHE"
    printf '#[fg=#9ece6a]↓%s #[fg=#f7768e]↑%s' "$(fmt 0)" "$(fmt 0)"
    exit 0
    ;;
esac

dt=$(( now - p_now ))

if [ "$dt" -ge "$MIN_INTERVAL" ]; then
  drx=$(( (rx - p_rx) / dt )); [ "$drx" -lt 0 ] && drx=0
  dtx=$(( (tx - p_tx) / dt )); [ "$dtx" -lt 0 ] && dtx=0

  # 物理的にあり得ない値（回線切替やカウンタ異常）は弾く
  [ "$drx" -gt 1250000000 ] && drx=0
  [ "$dtx" -gt 1250000000 ] && dtx=0

  tmpfile="${CACHE}.tmp.$$"
  printf '%s %s %s %s %s\n' "$now" "$rx" "$tx" "$drx" "$dtx" > "$tmpfile" && mv -f "$tmpfile" "$CACHE"
else
  # 前回の実測チェックポイントからまだ MIN_INTERVAL 秒経っていない:
  # チェックポイントは更新せず、前回算出済みのレートを使い回す
  drx=$p_drx
  dtx=$p_dtx
fi

printf '#[fg=#9ece6a]↓%s #[fg=#f7768e]↑%s' "$(fmt "$drx")" "$(fmt "$dtx")"
