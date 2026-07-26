eval "$(zoxide init bash --cmd cd)"

alias ls='eza --icons --group-directories-first'
alias l='eza --icons --group-directories-first -a'
alias cat='bat --paging=never --style=plain'
alias c='bat --paging=never --style=plain'
alias dif='difit'
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

