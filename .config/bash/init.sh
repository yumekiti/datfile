eval "$(zoxide init bash --cmd cd)"

if [[ $- == *i* ]]; then
  for bash_completion in \
    /opt/homebrew/etc/profile.d/bash_completion.sh \
    /usr/local/etc/profile.d/bash_completion.sh \
    /etc/bash_completion; do
    if [ -r "$bash_completion" ]; then
      . "$bash_completion"
      break
    fi
  done

  for blesh in \
    "$HOME/.local/share/blesh/ble.sh" \
    /opt/homebrew/share/blesh/ble.sh \
    /usr/local/share/blesh/ble.sh; do
    if [ -r "$blesh" ]; then
      . "$blesh"
      break
    fi
  done

  for bashopt in autocd cdspell dirspell checkwinsize histappend; do
    shopt -s "$bashopt" 2>/dev/null || true
  done

  bind 'set completion-ignore-case on' 2>/dev/null || true
  bind 'set show-all-if-ambiguous on' 2>/dev/null || true
  bind 'set show-all-if-unmodified on' 2>/dev/null || true
  bind 'set menu-complete-display-prefix on' 2>/dev/null || true
  bind 'set colored-stats on' 2>/dev/null || true
  bind 'set colored-completion-prefix on' 2>/dev/null || true
  bind 'TAB:menu-complete' 2>/dev/null || true
  bind '"\e[Z": menu-complete-backward' 2>/dev/null || true
  bind '"\e[A": history-search-backward' 2>/dev/null || true
  bind '"\e[B": history-search-forward' 2>/dev/null || true
  bind '"\C-p": history-search-backward' 2>/dev/null || true
  bind '"\C-n": history-search-forward' 2>/dev/null || true
fi

alias ls='eza --group-directories-first'
alias l='eza --group-directories-first -a'
alias cat='bat --paging=never --style=plain'
alias c='bat --paging=never --style=plain'
alias dif='difit'
alias v='code .'
alias x='codex'
clipbash() {
  pbpaste | /opt/homebrew/bin/bash
}

clipwrite() {
  if [ "$#" -ne 1 ]; then
    printf 'usage: clipwrite PATH\n' >&2
    return 2
  fi

  pbpaste > "$1"
}

vi() {
  if command -v difit >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if pgrep -f 'difit --keep-alive' >/dev/null 2>&1; then
      pkill -f 'difit --keep-alive' 2>/dev/null
      while pgrep -f 'difit --keep-alive' >/dev/null 2>&1; do
        sleep 0.1
      done
    fi
    ( difit --keep-alive </dev/null >/dev/null 2>&1 & )
  fi

  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}
