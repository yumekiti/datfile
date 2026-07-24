#!/usr/bin/env bash
# ネットワークの上り/下り瞬間速度を色付きで1発出力する（tmux status-right用）
#
# 前回サンプルとの差分から速度を算出。キャッシュへの書き込みは
# 「一時ファイルに書いてから rename」で原子的に行う（= 複数のtmuxクライアント/paneが
# 同時に読み書きしても、書きかけの壊れた行を掴んで変な値になるのを防ぐ）。
# 数値部分は幅を固定しているので、桁数が変わってもステータスバー全体がガタつかない。
#
# 呼び出し自体を MIN_INTERVAL 秒に間引く（OUT_CACHE）:
# tmuxは status-interval(2秒)ごとにしかこのスクリプトを呼ばない、という想定は
# 実際には成立しない。tmuxは pane の出力があるたびにもstatus lineを再描画し、
# その都度 #() job を再実行するため、Claude Codeが動いている（＝paneに出力が
# 出続けている）間は実測で1秒間に何度もこのスクリプトが呼ばれる（ai_thinking.sh
# の常駐スピナーが refresh-client -S を0.3秒毎に叩く間はさらに顕著）。
# netstat/route を毎回叩くとプロセスが積み上がり、CPU負荷にもなるため、直近の
# 描画結果をそのまま使い回して外部コマンドの起動自体をスキップする。
#
# サンプリング間隔も同じ MIN_INTERVAL 秒を保証する（レート計算用チェックポイント）。
# dt を date +%s の秒精度のまま使うと、1秒未満の間隔で連続実行された際にバイト
# 差分がほぼゼロなのに整数除算で 0B に丸められてしまう（実際に発生した不具合）。
# そのため直近の実測チェックポイントから MIN_INTERVAL 秒経つまでは新規計測を
# せず、前回算出済みのレートをそのまま使い回す。
#
# スリープ復帰やWi-Fi切替直後はインターフェースのバイトカウンタが巻き戻る
# （または新しいインターフェースに切り替わってCACHEが再作成される）ため、
# rx-p_rx が負になる瞬間がある。ここで即座に0にクランプすると、再接続処理が
# 落ち着くまでの数サイクル、表示が0に張り付いたように見えてしまう（実際に
# 発生した不具合）。そのため異常値（負や物理的にあり得ない値）が出た回は
# 新規計測を確定させず、前回算出済みのレートを引き継いで表示する。
# チェックポイント自体は毎回現在値で更新するので、カウンタが安定し次第
# 次サイクルから正しい実測値に復帰する。

MIN_INTERVAL=1

if [ "$(uname -s)" = "Darwin" ]; then
  IFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
  [ -z "$IFACE" ] && IFACE="en0"
else
  IFACE=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
fi

CACHE="${TMPDIR:-/tmp}/tmux_net_${IFACE}"
OUT_CACHE="${CACHE}.out"
now=$(date +%s)

# 直近の描画結果が MIN_INTERVAL 秒以内ならそれをそのまま返し、以降の
# netstat/route/fmt(awk) 呼び出しを丸ごと省略する。
if [ -r "$OUT_CACHE" ]; then
  { IFS= read -r c_ts; IFS= read -r c_out; } < "$OUT_CACHE" 2>/dev/null
  case "$c_ts" in
    *[!0-9]*|'') ;;
    *) [ $(( now - c_ts )) -lt "$MIN_INTERVAL" ] && { printf '%s' "$c_out"; exit 0; } ;;
  esac
fi

emit() {
  local tmpfile="${OUT_CACHE}.tmp.$$"
  { printf '%s\n' "$now"; printf '%s\n' "$1"; } > "$tmpfile" 2>/dev/null && mv -f "$tmpfile" "$OUT_CACHE"
  printf '%s' "$1"
  exit 0
}

if [ "$(uname -s)" = "Darwin" ]; then
  read -r rx tx < <(netstat -ibn 2>/dev/null | awk -v i="$IFACE" '$1==i{print $7, $10; exit}')
else
  rx=$(cat "/sys/class/net/${IFACE}/statistics/rx_bytes" 2>/dev/null)
  tx=$(cat "/sys/class/net/${IFACE}/statistics/tx_bytes" 2>/dev/null)
fi

if [ -z "$rx" ] || [ -z "$tx" ]; then
  emit '#[fg=#565f89]   no net'
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
    emit "$(printf '#[fg=#9ece6a]↓%s #[fg=#f7768e]↑%s' "$(fmt 0)" "$(fmt 0)")"
    ;;
esac

dt=$(( now - p_now ))

if [ "$dt" -ge "$MIN_INTERVAL" ]; then
  drxraw=$(( rx - p_rx ))
  dtxraw=$(( tx - p_tx ))

  # 負（カウンタ巻き戻り）や物理的にあり得ない値（回線切替やカウンタ異常）は
  # 実測不能とみなし、0にせず前回レートを引き継ぐ
  if [ "$drxraw" -lt 0 ]; then
    drx=$p_drx
  else
    drx=$(( drxraw / dt ))
    [ "$drx" -gt 1250000000 ] && drx=$p_drx
  fi
  if [ "$dtxraw" -lt 0 ]; then
    dtx=$p_dtx
  else
    dtx=$(( dtxraw / dt ))
    [ "$dtx" -gt 1250000000 ] && dtx=$p_dtx
  fi

  tmpfile="${CACHE}.tmp.$$"
  printf '%s %s %s %s %s\n' "$now" "$rx" "$tx" "$drx" "$dtx" > "$tmpfile" && mv -f "$tmpfile" "$CACHE"
else
  # 前回の実測チェックポイントからまだ MIN_INTERVAL 秒経っていない:
  # チェックポイントは更新せず、前回算出済みのレートを使い回す
  drx=$p_drx
  dtx=$p_dtx
fi

emit "$(printf '#[fg=#9ece6a]↓%s #[fg=#f7768e]↑%s' "$(fmt "$drx")" "$(fmt "$dtx")")"
