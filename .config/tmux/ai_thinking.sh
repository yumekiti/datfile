#!/usr/bin/env bash
# Claude CodeのUserPromptSubmitフックから叩かれ、そのpaneが属するwindowに
# 「AI思考中」フラグを立て、応答中はbrailleスピナーを回す。
# window-status-format側は @ai_thinking と @ai_spinner_frame を見るだけ（tmux.conf参照）。
#
# なぜ #() job を使わないか:
# tmux(1)に明記された「#()jobの出力がどれだけ速く更新されても、status line自体は
# 1秒に1回までしか再描画されない」というハード制限があるため。代わりに常駐ループが
# tmux set-option → refresh-client -S を直接叩いて明示的に再描画を強制する。
#
# なぜStop/PostToolUseフックに頼らないか:
# Stopフックは応答が自然に終わった時しか発火せず、ユーザーが中断（Escape等）した
# 場合は発火しない（公式ドキュメントに明記された既知の制約）。ハートビート＋
# タイムアウトで自動オフにする案も試したが、中断してから消えるまで最大数十秒
# 待たされてUXとして不十分だった。
# 代わりに、Claude Code自身がTUI最下部に表示する「esc to interrupt」という文字列を
# paneから直接ポーリングする。この文字列は自然終了・ユーザー中断のどちらでも応答が
# 止まった瞬間に画面から消えるので、フックの発火有無に関係なく実際の状態を
# ほぼリアルタイムに追える。
#
# $TMUX_PANE はtmuxがpane生成時にシェル環境へ自動で設定する変数。tmux外（他の
# 端末アプリ等）から呼ばれた場合は空になるので、その場合は何もせず抜ける。

POLL_INTERVAL=0.3
# ヒント文字列("esc to interrupt")は権限確認画面やツール呼び出しの合間などで
# 一瞬だけ描画から消えることがある。1回のミスで即オフにすると、AIがまだ動いて
# いるのにスピナーが消えて「止まった」ように見えるため、連続でこの回数ミスする
# までは「応答終了」と判定しない（約 POLL_INTERVAL * MISS_THRESHOLD 秒の猶予）。
MISS_THRESHOLD=3
# フック発火直後はまだTUIがヒント文字列を描画し切っていないことがある
# （実際に確認: 応答開始直後の数百ms〜1秒はまだ描画されておらず、そのまま
# だとMISS_THRESHOLD回連続ミスして本当に応答中なのにスピナーが即オフになる
# 不具合があった）。そのため「一度もヒントを見ていない」間はミス扱いにせず、
# 最初にヒントを検知してから初めてミスカウントを始める。ただし文字列が
# 想定と変わった等で永遠に見えないケースの保険として、STARTUP_GRACE回
# 経ってもまだ一度も見えなければ諦めてオフにする。
STARTUP_GRACE=50
FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

[ -n "$TMUX_PANE" ] || exit 0

# pane単位のループ多重起動防止。tmuxのoption show→setは2回の別コマンドで
# アトミックでないため（TOCTOU）、代わりにmkdirのアトミック性をロックとして使う。
LOCK_DIR="${TMPDIR:-/tmp}/ai_thinking_${TMUX_PANE#%}.lock"

case "$1" in
  on)
    tmux set-option -w -t "$TMUX_PANE" @ai_thinking 1 2>/dev/null

    if mkdir "$LOCK_DIR" 2>/dev/null; then
      # stdin/stdout/stderrをこのフック呼び出し元から明示的に切り離す。
      # `&`でバックグラウンド化しても、リダイレクトしない限りfd自体は
      # 継承されたまま=このループが動いている間ずっと開きっぱなしになる。
      # Claude Code側がフックのstdoutがEOFになるのを応答進行の条件にしている場合、
      # ループの終了条件（=応答が終わって"esc to interrupt"が消えること）と
      # 循環依存になり、応答が永久に完了しなくなる（実際に発生した不具合）。
      (
        trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT
        i=0
        misses=0
        seen=0
        n=${#FRAMES[@]}
        while true; do
          # 起動直後の1回目だけはヒント文字列がまだ描画されていない可能性が
          # あるので判定をスキップする（即座に誤ってオフにしないため）。
          if [ $i -gt 0 ]; then
            if tmux capture-pane -p -t "$TMUX_PANE" 2>/dev/null | grep -q "esc to interrupt"; then
              seen=1
              misses=0
            elif [ "$seen" -eq 1 ]; then
              misses=$((misses + 1))
              if [ "$misses" -ge "$MISS_THRESHOLD" ]; then
                tmux set-option -w -t "$TMUX_PANE" -u @ai_thinking 2>/dev/null
                break
              fi
            elif [ "$i" -ge "$STARTUP_GRACE" ]; then
              tmux set-option -w -t "$TMUX_PANE" -u @ai_thinking 2>/dev/null
              break
            fi
          fi

          tmux set-option -w -t "$TMUX_PANE" @ai_spinner_frame "${FRAMES[$((i % n))]}" 2>/dev/null
          while IFS= read -r c; do
            [ -n "$c" ] && tmux refresh-client -S -t "$c" 2>/dev/null
          done < <(tmux list-clients -F '#{client_name}' 2>/dev/null)

          i=$((i + 1))
          sleep "$POLL_INTERVAL"
        done
        tmux set-option -w -t "$TMUX_PANE" -u @ai_spinner_frame 2>/dev/null
      ) >/dev/null 2>&1 </dev/null & disown
    fi
    ;;
  off)
    # フック自動化からは外したが、手動フォールバック用に残す。
    tmux set-option -w -t "$TMUX_PANE" -u @ai_thinking 2>/dev/null
    ;;
esac

exit 0
